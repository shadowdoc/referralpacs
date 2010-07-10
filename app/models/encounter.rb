class Encounter < ActiveRecord::Base
  validates_presence_of :date
  belongs_to :patient
  belongs_to :encounter_type
  belongs_to :location
  belongs_to :provider
  belongs_to :client
  has_many :images, :dependent => :delete_all
  has_many :observations, :dependent => :delete_all
  after_save :write_hl7
  
  attr_protected :created_at, :created_by, :updated_at, :updated_by

  def self.find_range(start_date = Time.now.strftime("%y-%m-%d"), end_date = Time.now.strftime("%y-%m-%d"))
    #This method returns encounters between the given dates
    #If no dates are given, these default to today
    Encounter.find(:all, :conditions => ['date between ? and ?', start_date, end_date])
  end

  def write_hl7
    if self.status == "ready_for_printing"
      # This method generates complete HL7 message stored in RAILS ROOT/public/hl7_development

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


      # First we create the directory
      path = File.join(RAILS_ROOT, OPENMRS_HL7_PATH, self.date.year.to_s, self.date.month.to_s, self.date.day.to_s)
      filename = File.join(path, self.date.strftime("%Y-%m-%d") + "-" + self.id.to_s + ".hl7")

      FileUtils.mkdir_p path

      tango = File.new(filename, "w+")
      tango.puts(msg.to_s) # string version of the hl7 message
      tango.close
    end
  end
  

end
