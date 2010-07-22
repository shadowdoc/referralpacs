class Encounter < ActiveRecord::Base

  validates_presence_of :date
  belongs_to :patient
  belongs_to :encounter_type
  belongs_to :location
  belongs_to :provider
  belongs_to :client
  has_many :images, :dependent => :delete_all
  has_many :observations, :dependent => :delete_all
  after_save :send_hl7
  
  attr_protected :created_at, :created_by, :updated_at, :updated_by

  def self.find_range(start_date = Time.now.strftime("%y-%m-%d"), end_date = Time.now.strftime("%y-%m-%d"))
    #This method returns encounters between the given dates
    #If no dates are given, these default to today
    Encounter.find(:all, :conditions => ['date between ? and ?', start_date, end_date])
  end

  def hl7_message
    # These fields are customizations for OpenMRS HL7 formatting
    HL7::Message::Segment::OBR.class_eval { add_field(:identifier, :idx => 4) }
    HL7::Message::Segment::ORU.class_eval { add_field(:order_control, :idx => 1) }
    HL7::Message::Segment::ORU.class_eval { add_field(:transaction_date_time, :idx => 9) }
    HL7::Message::Segment::ORU.class_eval { add_field(:entered_by, :idx => 10) }

    msg = HL7::Message.new
    msg << ApplicationController.hl7_msh
    msg << patient.hl7_pid
    pv1 = HL7::Message::Segment::PV1.new
    oru = HL7::Message::Segment::ORU.new
    obr = HL7::Message::Segment::OBR.new

    pv1.set_id = '1'
    pv1.patient_class = 'O'
    pv1.assigned_location = '^^^^^^^^^?^MTRHRADIOLOGY'
    pv1.admission_type = '2'
    pv1.attending_doctor = '1^' + client.hl7_name + '^^^^8^M10^^MTRHRAD'
    pv1.admit_date = date.strftime("%Y%m%d%H%M%S")
    pv1.visit_indicator = 'V'
    msg << pv1

    oru.order_control = 'RE'
    oru.transaction_date_time = self.date.strftime("%Y%m%d%H%M%S")
    oru.entered_by = '1^' + provider.hl7_name + '^^^^8^M10^^MTRHRAD'
    msg << oru

    obr.identifier = '2395^CHEST X-RAY FINDINGS BY RADIOLOGY^99DCT'
    obr.filler_order_number = self.id
    msg << obr


    #Now we'll build the OBX segments for the observations that we have

    self.observations(true).each do |obs|
      # First we create an array that has all of the obx segment objects for this observation.

      tmp = []
      tmp = tmp | obs.obx

      # Now we'll go through each of the segments and add them to the message
      # This is necessary for the times when the create_obx method returns
      # more than one OBX segment

      tmp.each { |obx| msg << obx }

    end

    # Now we will add the OBX|RP segments for pointers to the images

    self.images.each do |image|
      obx = HL7::Message::Segment::OBX.new
      obx.value_type = "RP"
      obx.observation_value = image.id
      msg << obx
    end

    #TODO Now, let's add the OBX that includes the uuencoded thumbnail

    # Add the impression OBX to the message

    unless self.impression.nil?
      obx = HL7::Message::Segment::OBX.new
      obx.value_type = 'ST'
      obx.observation_id = '????^CHEST X-RAY IMPRESSION^99DCT'
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

     return msg
  end

  def send_hl7

      unless self.patient.openmrs_verified?
        # Calling the find_openmrs method will search based on this patient's current mrn_ampath
        # If the method finds a new patient, the current patient object will be updated.
        Patient.find_openmrs(self.patient.mrn_ampath)
      end

    if self.status == "ready_for_printing" && self.patient.openmrs_verified?

      msg = self.hl7_message

      if OPENMRS_HL7_PATH
        file_write_hl7(msg)
      end

      if OPENMRS_HL7_REST
        rest_hl7(msg)
      end
      
    end

  end

  def rest_hl7(msg)
    # URL Specification
    # http://myhost:serverport/openmrs/moduleServlet/restmodule/api/hl7?message=my_hl7_message_string&source=myHl7SourceName
    # from: http://openmrs.org/wiki/REST_Module

    url = OPENMRS_URL_BASE + "hl7/"

    # Create a URI object from our url string.
    url = URI.parse(url)

    # Create a request object from our url and attach the authorization data.
    req = Net::HTTP::Put.new(url.path)
    req.basic_auth(OPENMRS_USERNAME, OPENMRS_PASSWORD)
    req.set_form_data({'MESSAGE' => msg.to_s, 'SOURCE' => 'REFPACS'})
    
    http = Net::HTTP.new(url.host, url.port)

    http.use_ssl = true
    
    begin
      #result = http.request(req)
    rescue
      $openmrs_down = true

      puts "****************OPEN MRS DOWN*********************"

      # Let's save the message into a folder so they can be queued
      path = File.join(RAILS_ROOT, OPENMRS_HL7_PATH, "queue")
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

  def file_write_hl7(msg)
    if self.status == "ready_for_printing"

      # First we create the directory
      path = File.join(RAILS_ROOT, OPENMRS_HL7_PATH)
      filename = File.join(path, self.date.strftime("%Y-%m-%d") + "-" + self.id.to_s + ".hl7")

      tango = File.new(filename, "w+")
      tango.puts(msg.to_s) # string version of the hl7 message
      tango.close
    end

  end
  

end
