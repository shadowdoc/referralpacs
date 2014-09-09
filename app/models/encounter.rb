class Encounter < ActiveRecord::Base

  validates_presence_of :date, :encounter_type
  belongs_to :patient
  belongs_to :encounter_type
  belongs_to :location
  belongs_to :provider
  belongs_to :client
  has_many :images, :dependent => :delete_all
  has_many :observations, :dependent => :delete_all
  has_many :quality_checks
  after_save :send_hl7
  
  attr_protected :created_at, :updated_at

  def hl7_message

    msg = HL7::Message.new
    msg << ApplicationController.hl7_msh
    msg << patient.hl7_pid
    pv1 = HL7::Message::Segment::PV1.new
    orc = HL7::Message::Segment::ORU.new
    obr = HL7::Message::Segment::OBR.new

    #pv1.set_id = '1'     # I don't think this field is used.'
    pv1.patient_class = 'O'
    pv1.assigned_location = '1^Unknown Location'
    #pv1.admission_type = '2'   # This is not used either


    # Encounters generated from DICOM messages don't have valid clients.
    client_name = client ? client.hl7_name : ""

    pv1.attending_doctor = '1^' + client_name
    pv1.admit_date = date.strftime("%Y%m%d%H%M%S")
    pv1.visit_indicator = 'V'
    msg << pv1

    orc.e0 = "ORC" # For some reason the ruby-hl7 names this ORU rather than ORC - typo??
    orc.order_control = 'RE'
    orc.transaction_date_time = self.date.strftime("%Y%m%d%H%M%S")
    orc.entered_by = '1^' + provider.hl7_name
    msg << orc

    obr.identifier = '2395^CHEST X-RAY FINDINGS BY RADIOLOGY^99DCT'
    obr.filler_order_number = self.id
    msg << obr


    #Now we'll build the OBX segments for the observations that we have

    current_sub_id = 1 # Start with a sub_id of 1 and increment with each observation

    self.observations(true).each do |obs|
      # First we create an array that has all of the obx segment objects for this observation.

      tmp = []
      tmp = tmp | obs.obx(current_sub_id)

      # Now we'll go through each of the segments and add them to the message
      # This is necessary for the times when the create_obx method returns
      # more than one OBX segment

      tmp.each { |obx| msg << obx }

      current_sub_id += 1 # increment the sub_id

    end

    # Now we will add the OBX|RP segments observations

    #TODO This is commented out because the 1.8 openmrs HL7 processor does not yet accept RP

    #self.images.each do |image|
    #  obx = HL7::Message::Segment::OBX.new
    #  obx.value_type = "RP"
    #  obx.observation_value = image.id.to_s + "^REFPACS^#{self.encounter_type.modality}"
    #  msg << obx
    #end

    #TODO Now, let's add the OBX that includes the uuencoded thumbnail

    # Add the impression OBX to the message

    unless self.impression.nil?
      obx = HL7::Message::Segment::OBX.new
      obx.value_type = 'ST'
      obx.observation_id = '6115^CHEST X-RAY IMPRESSION^99DCT'
      obx.e11 = 'F'
      obx.time = self.date.strftime("%Y%m%d%H%M%S")

      impression_temp = impression
      # stipulated character substitutions, backslash needs to be first
      impression_temp = impression_temp.gsub( /\\/, '\E\\' )
      impression_temp = impression_temp.gsub( /\|/, '\F\\' )
      impression_temp = impression_temp.gsub( /\^/, '\S\\' )
      impression_temp = impression_temp.gsub( /&/, '\T\\' )
      impression_temp = impression_temp.gsub( /~/, '\R\\' )
      obx.observation_value = impression_temp
      msg << obx
    end

    msg  # This returns the fully formed message
  end

  def pdf_report
    pdf = Prawn::Document.new({:page_size => 'A4',
                              :left_margin => 50,
                              :right_margin => 50,
                              :top_margin => 24,
                              :bottom_margin => 24})


    pdf.instance_eval do
       def separator
          text " "
          stroke {y=@y-25; line [1,y], [bounds.width,y]}
          text " "
       end
    end


    header_image = File.open(Rails.root.join("app/assets/images/mtrhlogo.jpg"))
    pdf.image(header_image, :scale => 0.25, :align => :center)
    header_image.close


    pdf.text "PO Box 3, 3100 Eldoret Tel: +254-053-2033471/4", :size => 14, :align => :center
    pdf.text "Chest X-ray Report", :size => 18, :align => :center
    pdf.move_down(5)
    pdf.separator
    pdf.move_down(10)

    pdf.text "Patient: #{patient.full_name}", :size => 14, :justification => :left
    pdf.text "ID: #{patient.mrn_ampath}"
    pdf.text "X-ray ID #{patient.mtrh_rad_id}"
    pdf.text "Birthdate: #{patient.birthdate.strftime("%d-%m-%y")}"
    pdf.move_down(10)
    pdf.text "Film Date: #{date.strftime("%d-%m-%y")}"
    pdf.text "Report Date: #{updated_at.strftime("%d-%m-%y")}"
    pdf.move_down(5)
    pdf.separator
    pdf.move_down(10)

    pdf.text "Clinical History:", :size => 14
    pdf.text "#{indication}", :size => 12
    pdf.move_down(5)
    pdf.separator
    pdf.move_down(10)


    pdf.text "Observations", :size => 15
    observations.each do |o|

      pdf.text "#{o.question_concept.name} - #{o.value_concept.name}"

    end

    pdf.move_down(5)
    pdf.separator
    pdf.move_down(10)

    pdf.text("Impression:", :size => 15)
    pdf.text(impression)
    pdf.move_down(20)
    pdf.text "Reported and Signed by: #{provider.full_name}"
    
    pdf.render

  end

  def send_hl7

    if self.status == "ready_for_printing" && self.patient.openmrs_verified?

      if OPENMRS_HL7_PATH
        file_write_hl7
      end

      if OPENMRS_HL7_REST
        rest_hl7
      end
      
    end

  end

  def rest_hl7
    # URL Specification
    # http://myhost:serverport/openmrs/moduleServlet/restmodule/api/hl7?message=my_hl7_message_string&source=myHl7SourceName
    # from: http://openmrs.org/wiki/REST_Module

    msg = hl7_message

    url = OPENMRS_URL_BASE + "hl7/"      # The trailing slash here is critical.

    # Create a URI object from our url string.
    url = URI.parse(url)

    # Create a request object from our url and attach the authorization data.
    req = Net::HTTP::Post.new(url.path)
    req.basic_auth(OPENMRS_USERNAME, OPENMRS_PASSWORD)
    req.set_form_data({'message' => msg.to_s.gsub(/\n/, "\r"), 'source' => OPENMRS_SENDING_FACILITY})
    
    http = Net::HTTP.new(url.host, url.port)

    if OPENMRS_URL_BASE.slice(4,1) == "s"
      http.use_ssl = true
    end


    begin
      result = http.request(req)
      logger.info "REST SUCCESS - Encounter #{self.id} posted to: #{OPENMRS_URL_BASE} #{result.inspect}"
    rescue
      $openmrs_down = true
      logger.warn "REST FAILURE - Encounter #{self.id} post failed url: #{url}"

      # Let's save the message into a folder so they can be queued
      path = Rails.root.join(OPENMRS_HL7_PATH, "queue")
      filename = File.join(path, self.date.strftime("%Y-%m-%d") + "-" + self.id.to_s + ".hl7")

      tango = File.new(filename, "w+")
      tango.puts(msg.to_s) # string version of the hl7 message
      tango.close
    end
    result
  end


  def file_write_hl7

    if self.status == "ready_for_printing"

      msg = hl7_message

      # First we create the directory
      path = Rails.root.join(OPENMRS_HL7_PATH)
      filename = File.join(path, self.date.strftime("%Y-%m-%d") + "-" + self.id.to_s + ".hl7")

      tango = File.new(filename, "w+")
      tango.puts(msg.to_s) # string version of the hl7 message
      tango.close
    end

  end

  def update
    # This code will move images from one encounter date to another, making the change much easier.

    old_date = Encounter.find(self.id).date

    super

    if old_date != self.date
      if self.images.length != 0
        self.images.each do |image|
          image.change_encounter_date(old_date)
        end
      end
    end
    super
  end


  def self.new_dcm4chee(dcm_study)
    # This method is called from the script that reads from the dcm4chee database.
    # It recieves a dcm4chee_study object, and then does several actions including
    # finding or creating a new patient.

    # Right now we are only accepting CRs so we will only accept images from that SOP class

    if dcm_study.dcm4chee_series[0].dcm4chee_instances[0].sop_cuid == "1.2.840.10008.5.1.4.1.1.1"

      dcm_patient = dcm_study.dcm4chee_patient
      dcm_mrn = dcm_patient.pat_id

      patient = Patient.find_openmrs(dcm_mrn)

      if patient.nil?
        # We have a new patient, but the OpenMRS server appears to be down or doesn't know the patient.
        patient = Patient.new

        patient.mrn_ampath = dcm_mrn
        patient.family_name, patient.given_name, patient.middle_name = dcm_patient.pat_name.split("^") # Standard HL7 names are used in DICOM
        patient.birthdate = dcm_patient.pat_birthdate

        begin
          patient.save!
        rescue
          # We have an error creating the patient.  Let's write it out to a log file
          # and set the study_status in the dcm4chee to -1

          logfile = Rails.root.join("log", "dicom_patient_errors.log")
          File.open(logfile, 'a+') do |f|
            f.write("Invalid Patient: #{patient.hl7_name} OpenMRS MRN: #{patient.mrn_ampath} Accession Number: #{dcm_study.accession_no}\n")
          end

          dcm_study.study_status = -1
          dcm_study.save
        end

      end

      unless dcm_study.study_status == -1
        enc = Encounter.new
        enc.patient_id = patient.id
        enc.date = dcm_study.study_datetime
        enc.indication = "#{dcm_study.study_custom1} #{dcm_study.study_custom2}".strip
        enc.status = "new"
        enc.study_uid = dcm_study.study_iuid
        enc.encounter_type_id = 1 # These are all CXRs
        enc.save!

        # Loop through each series to make sure we get all of the CXRs

        dcm_study.dcm4chee_series.each do |s|
          s.dcm4chee_instances.each do |i|
            image = Image.new
            image.encounter_id = enc.id
            image.instance_uid = i.sop_iuid
            image.save!
          end
        end

        # We successfully loaded this encounter, let's set our status to 1

        dcm_study.study_status = 1
        dcm_study.save!

      end

    end
    # return the created encounter
    enc
  end 

end
