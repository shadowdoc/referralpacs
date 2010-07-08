class Patient < ActiveRecord::Base
  has_many :encounters
  belongs_to :tribe
  
  validates_presence_of :given_name, :family_name
  validates_uniqueness_of :mtrh_rad_id, :allow_blank => true                          
  validates_uniqueness_of :mrn_ampath, :allow_blank => true
  
  before_save :uppercase
 
  require "net/https"
  require "net/http"
  
  #Provide a concatenated name for cleaner display.
  def full_name
    unless self.given_name.nil? || self.family_name.nil?
      self.given_name + " " + self.family_name
    end
  end
  
  def current_age
    dob = self.birthdate
    a = Date.today.year - dob.year
    b = Date.new(Date.today.year, dob.month, dob.day)
    a = a - 1 if b > Date.today
    return a
  end
  
  def hl7_name
    # Create a correctly formatted name for HL7

    # Patient Name
    # Patient^Jonny^Dee^^DR| 
    #    Family Name (Patient) 
    #    ^ Given Name (Jonny) 
    #    ^ Second / Middle Name (Dee) 
    #    ^ Suffix () 
    #    ^ Prefix (DR) 
    
    # In our system, family_name and given_name are required
    # middle_name is not required, and can be nil

    name = dicom_name
    name += "^^"  # We don't use suffixes or prefixes
   
    return name
  end
  
  def dicom_name
    # Create a correctly formatted name for DICOM saves.
    
    name = family_name + "^" + given_name + "^"
    name += middle_name unless middle_name.nil?
    return name
  end
  
  def dicom_birthday
    return birthdate.strftime("%Y%m%d")
  end
  
  def hl7_birthday
    # 20040101000000| 
    #    Date/Time of Birth (YYYYMMDDHHMMSS) 
    #    ^ Degree of Precision (for our purposes Y = estimated, and null = actual)
    if birthdate_estimated
      precision = "Y"
    else
      precision = ""
    end
    
    return birthdate.strftime("%Y%m%d%H%M%S") + "^" + precision
    
  end
  
  def hl7_sex
    if self.gender = "Male"
      return "M"
    else
      if self.gender = "Female"
        return "F"
      else
        return "U"
      end
    end
  end
    
  def hl7_pid
    
    # Create a new pid object to hold our info
    pid = HL7::Message::Segment::PID.new    

    # Split the AMPATH MRN into it's ID and check digit
    ampath_id, check_digit = mrn_ampath.split("-")
    
    # Patient Id List
    # 1MT^0^M10| 
    #    ID Number (1MT) 
    #    ^ Check Digit (0) 
    #    ^ Check Digit Scheme (M10) 
    #    ^ Assigning Authority (hopefully won't have to use.. but if we need multiples) 
    #    // a ~ would separate multiple occurrences of PIDs
    pid.patient_id_list = ampath_id + "^" + check_digit + "^M10"
    
    # Patient Name
    # Patient^Jonny^Dee^^DR| 
    #    Family Name (Patient) 
    #    ^ Given Name (Jonny) 
    #    ^ Second / Middle Name (Dee) 
    #    ^ Suffix () 
    #    ^ Prefix (DR) 
   
    pid.patient_name = hl7_name
    
    # Patient^Momma^Thee^^MS| 
    #    Mother's Maiden Family Name (Patient) 
    #    ^ Given Name (Momma) 
    #    ^ Second / Middle Name (Thee) 
    #    ^ Suffix () 
    #    ^ Prefix (MS)
    #pid.mothers_maiden_name = 
    
    # 20040101000000| 
    #    Date/Time of Birth (YYYYMMDDHHMMSS) 
    #    ^ Degree of Precision (for our purposes Y = estimated, and null = actual)
    
    pid.patient_dob = hl7_birthday
    
    # M| 
    #    Administrative Sex (M) .. M, F, O, U, A, N possible answers
    # Will set to unkown for now, we don't have good verification to these types.
    pid.admin_sex = hl7_sex
    
    # 555 Johnson Road^Apt. 555^Indianapolis^IN^46202^USA| 
    #    Street Address 
    #    ^ Other Designation 
    #    ^ City 
    #    ^ State 
    #    ^ Zip
    # We're not using this as we don't often have address information.  We're not the gold standard anyway!
    #pid.address = address1 unless address1.nil? + "^" + address2 unless address2.nil? + "^" + city_village unless city_village.nil? + "^" + state_province unless state_province.nil?

    # The remaining pid fields are unused at the current time.
    
    return pid

  end
  
  def birthdate_formatted
    self.birthdate.strftime("%d %b %Y") unless self.birthdate.nil?
  end
  
  def uppercase
    write_attribute :family_name, family_name.upcase
    write_attribute :middle_name, middle_name.upcase unless middle_name.nil?
    write_attribute :given_name, given_name.upcase
  end
  
  def Patient.search(params)
    # This Class method allows for specific searching of patients based on the several parameters
    # The search returns a list of patients

    patients = []

    # AMPATH mrn is the best identifier, so let's see if we have one of those first
    unless params[:patient][:mrn_ampath] == ""
            
       if $openmrs
         # This means we can search for patients using the REST service
         # This method will find new patients, and will also verify existing OpenMRS patients
         patients << Patient.find_openmrs_patient(params[:patient][:mrn_ampath])
       else
         # Have to look these patients up locally.
         patients << Patient.find_by_mrn_ampath(params[:patient][:mrn_ampath])
       end

      
    else
      # If we don't have an AMPATH ID, what about a MTRH radiology id?

      unless params[:patient][:mtrh_rad_id] == ""
        patients = Patient.find(:all,
                    :conditions => ['mtrh_rad_id = ?', params[:patient][:mtrh_rad_id]])
      else
        # We're left to search names or filter encounters by date to get patient names
        unless params[:patient][:name] == ""
          patients = Patient.find(:all,
                      :conditions => ['LOWER(CONCAT(given_name, " ", family_name)) LIKE ?', '%' + params[:patient][:name].downcase + '%'])
        end
      end
    end
    
    return patients
    
  end
  
  def Patient.find_openmrs_patient(mrn_openmrs)
    # This method takes an OpenMRS identifier, communicates with the OpenMRS REST interface and then
    # uses REXML to process the response.
    #
    # All of the globals below are set in config/openmrs.conf.rb

    # We were given an openmrs identifier, so we have a few tasks
    # Find a local patient with this mrn
    # Search the openmrs server for patients with this mrn
    # Either update the existing patient with the new demographic information OR create a new patient object
    
    if $openmrs_ssl
      url = "https://"
    else
      url = "http://"
    end

    url += "#{$openmrs_server}/amrs/moduleServlet/restmodule/api/patient/#{mrn_openmrs}"
    
    # Create a URI object from our url string.
    url = URI.parse(url)

    # Create a request object from our url and attach the authorization data.
    req = Net::HTTP::Get.new(url.path)
    req.basic_auth($openmrs_user, $openmrs_password)
    
    http = Net::HTTP.new(url.host, url.port)
    
    http.use_ssl = $openmrs_ssl
    
    begin
      result = http.request(req)
    rescue
      $openmrs_down = true
    end

    doc = REXML::Document.new(result.read_body) unless result.nil?

    # Find any local patient that belongs to the given identifier
    patient = Patient.find_by_mrn_ampath(mrn_openmrs)

    # Let's see if we got a good result from openmrs

    unless doc.nil? || doc.elements["//identifier"].nil?
      $openmrs_server_status = "up"

      # We got a good result - let's see if we already know this patient

      if patient.nil?
        # This is a new patient, so let's create a new patient object
        patient = Patient.new
        patient.update_via_xml(doc)
        patient.save!
      else
        # Update the patient record with the latest info from openmrs server
        patient.update_via_xml(doc)
        patient.save!
      end
    end

    return patient

  end
  
  def update_via_xml(doc)
    # This method takes a REXML document and updates a patient object

    mrn_ampath = doc.elements["//identifier"].text unless doc.elements["//identifier"].nil?
    given_name = doc.elements["//givenName"].text unless doc.elements["//givenName"].nil?
    middle_name = doc.elements["//middleName"].text unless doc.elements["//middleName"].nil?
    family_name = doc.elements["//familyName"].text unless doc.elements["//familyName"].nil?
    birthdate = DateTime.parse(doc.elements["//@birthdate"].to_s) unless doc.elements["//@birthdate"].nil?
    birthdate_estimated = doc.elements["//@birthdateEstimated"] unless doc.elements["//@birthdateEstimated"].nil?
    address1 = doc.elements["//address1"].text unless doc.elements["//address1"].nil?
    address2 = doc.elements["//address2"].text unless doc.elements["//address2"].nil?
    city_village = doc.elements["//cityVillage"].text unless doc.elements["//cityVillage"].nil?
    state_province = doc.elements["//stateProvince"].text unless doc.elements["//stateProvince"].nil?
    country = doc.elements["//country"].text unless doc.elements["//country"].nil?
    mtrh_rad_id = nil
    openmrs_verified = true

  end
  
  def validate
    # Here is where we check the check digit supplied with the AMPATH ID
    
    # Create a string of valid characters
    valid_chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVYWXZ_"
    
    
    # Upcase and split our mrn_ampath
    id_array = self.mrn_ampath.upcase.split("-")
    
    id_without_check_digit = id_array[0]
    check_digit = id_array[1]
    
    # setup variables for sum and position tracking
    sum = 0
    pos = 0
    weights = []
    sums = []
    
    id_without_check_digit.reverse.each_char do |digit|
      # Make sure we only have valid characters
      if !valid_chars.include? digit
        errors.add_to_base "Invalid Character in AMPATH-ID"
      end
      
      digit = digit[0] - 48
      
      if (pos % 2 == 0)
 
        # for alternating digits starting with the rightmost, we
        # use our formula this is the same as multiplying x 2 and
        # adding digits together for values 0 to 9.  Using the 
        # following formula allows us to gracefully calculate a
        # weight for non-numeric "digits" as well (from their 
        # ASCII value - 48).
        weight = (2 * digit) - ((digit / 5).to_i * 9);
 
      else
   
        # even-positioned digits just contribute their ascii
        # value minus 48
        weight = digit;
   
      end
 
      # keep a running total of weights
      sum += weight
      weights << weight
      sums << sum
      
      # increment the position 
      pos += 1
    end
    
    # avoid sums less than 10
    sum = sum.abs + 10
    
    if check_digit.to_i != (10 - (sum % 10)) % 10
      errors.add_to_base "Invalid AMPATH ID, please correct"
    end
    
  end
  
  def last_location
    if self.encounters.count == 0 || self.encounters.last.location.nil?
      return "No encounters"
    else
      return self.encounters.last.location.name
    end
  end

end
