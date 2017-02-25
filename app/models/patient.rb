class Patient < ActiveRecord::Base
  has_many :encounters, :dependent => :destroy
  belongs_to :tribe

  validates_presence_of :given_name, :family_name
  validates_uniqueness_of :mtrh_rad_id, :allow_blank => true
  validates_uniqueness_of :mrn_ampath, :allow_blank => true

  before_save :uppercase
  attr_accessible :mrn_ampath, :mtrh_rad_id, :given_name, :middle_name, :family_name, :gender,
                  :tribe_id, :address1, :address2, :birthdate, :birthdate_estimated,
                  :city_village, :state_province, :city_village, :country

  #Provide a concatenated name for cleaner display.
  def full_name

    unless self.given_name.nil? || self.family_name.nil?
      if self.middle_name.nil?
        self.given_name + " " + self.family_name
      else
        self.given_name + " " + self.family_name + " "+ self.middle_name
      end
    end

  end

  def current_age
    if self.birthdate.nil?
      return "Unknown"
    else
      dob = self.birthdate
      a = Date.today.year - dob.year
      b = Date.new(Date.today.year, dob.month, dob.day)
      a = a - 1 if b > Date.today
    end
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

    name = family_name + "^"
    name += given_name + "^" unless given_name.nil?
    name += middle_name unless middle_name.nil?
    return name
  end

  def dicom_birthday
    birthdate.strftime("%Y%m%d")
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

    birthdate.strftime("%Y%m%d%H%M%S") + "^" + precision

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
    pid.patient_id_list = mrn_ampath + "^" + check_digit + "^M10^AMRS Universal ID^"

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

    #pid.patient_dob = hl7_birthday
    pid.patient_dob = ""

    # M|
    #    Administrative Sex (M) .. M, F, O, U, A, N possible answers
    # Will set to unknown for now, we don't have good verification to these types.
    #pid.admin_sex = hl7_sex
    #pid.admin_sex = ""

    # 555 Johnson Road^Apt. 555^Indianapolis^IN^46202^USA|
    #    Street Address
    #    ^ Other Designation
    #    ^ City
    #    ^ State
    #    ^ Zip
    # We're not using this as we don't often have address information.  We're not the gold standard anyway!
    #pid.address = address1 unless address1.nil? + "^" + address2 unless address2.nil? + "^" + city_village unless city_village.nil? + "^" + state_province unless state_province.nil?
    #pid.address = ""

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
    write_attribute :mrn_ampath, mrn_ampath.upcase
  end

  def update_via_json(person)
    # This method takes a JSON response from OpenMRS and updates a patient object

    logger.debug("Processing JSON message: #{person}")

    names = person["preferredName"]["display"].split(" ")

    if names.length == 3
      self.given_name, self.middle_name, self.family_name = names
    end

    if names.length == 2
      self.given_name, self.family_name = names
    end

    if names.length == 1
      self.family_name = names[0]
    end

    self.birthdate = DateTime.parse(person["birthdate"]) unless person["birthdate"].nil?

    self.birthdate_estimated = person["birthdateEstimated"] unless person["birthdateEstimated"].nil?

    # This is going to be tough to parse, and adds limited value to our database
    # Will leave them out for now.

    # self.address1 =
    # self.city_village =
    # self.state_province =
    # self.country =

    self.mtrh_rad_id = nil
    self.openmrs_verified = true
    self.save!

  end

  def last_location
    if self.encounters.count == 0 || self.encounters.last.location.nil?
      return "No encounters"
    else
      return self.encounters.last.location.name
    end
  end

  def recent_encounters
    # This returns an array of the last 5 encounters
    # this method is used in the image display to provide easy access
    # to prior encounters

    # Pull an array of the comparison exams, sorted by date.

    array = self.encounters.sort! {|x, y| y.date <=> x.date }
    recent = []


    # Only include encounters that have images.
    array.each do |comp|
      if !comp.images.empty?
        recent << comp
      end
    end

    # Limit @comparisons to 5
    recent = recent.to(4).from(1) if recent.length > 5

    recent
  end


  # This method takes any ID number and runs it through the check digit
  # algorithm
  def Patient.check_digit(id_number)
    # Create a string of valid characters
    valid_chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVYWXZ_"

    # Upcase and split our mrn_ampath
    id_array = id_number.upcase.split("-")

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
        return false
      end

      digit = digit.ord - 48

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

    check_digit.to_i == ((10 - (sum % 10)) % 10) ? true : false

  end


  def Patient.search(params)
    # This Class method allows for specific searching of patients based on the several parameters
    # The search returns a list of patients

    patients = []

    # AMPATH mrn is the best identifier, so let's see if we have one of those first
    unless params[:patient][:mrn_ampath] == ""

      if OPENMRS_URL_BASE
        # This means we can search for patients using the REST service
        # This method will find new patients, and will also verify existing OpenMRS patients
        openmrs_patient = Patient.find_openmrs(params[:patient][:mrn_ampath])
        unless openmrs_patient.nil?
           patients << openmrs_patient
        end
      end

    else
      # If we don't have an AMPATH ID, what about a MTRH radiology id?

      unless params[:patient][:mtrh_rad_id] == ""
        patients = Patient.where('mtrh_rad_id = ?', params[:patient][:mtrh_rad_id])
      else
        # We're left to search names or filter encounters by date to get patient names
        unless params[:patient][:name] == ""
          patients = Patient.where('LOWER(CONCAT(given_name, " ", family_name)) LIKE ?', '%' + params[:patient][:name].downcase + '%')
        end
      end
    end

    if patients.length == 0 || patients[0].nil?
      patients = nil
    end

    return patients

  end


  def Patient.find_openmrs(mrn_openmrs)
    # All of the globals below are set in config/initializers/openmrs.rb from config/openmrs.yml

    # We were given an openmrs identifier, so we have a few tasks
    # - Search the openmrs server for patients with this mrn
    # - Find a local patient with this mrn, if one exists
    # - Either update the existing patient with the new demographic information OR create a new patient object

    if OPENMRS_URL_BASE.nil?
      # Not integrated with an OpenMRS install.  Find any local patient that belongs to the given identifier
      patient = Patient.find_by_mrn_ampath(mrn_openmrs)
      return patient
    end

    url = OPENMRS_URL_BASE + "patient/?q=" + mrn_openmrs

    begin
      result = RestClient::Request.execute(:url => url,
                                           :user => OPENMRS_USERNAME,
                                           :password => OPENMRS_PASSWORD,
                                           :method => :get,
                                           :verify_ssl => OpenSSL::SSL::VERIFY_NONE,
                                           :headers => {'Accept' => :json})
    rescue => e
      $openmrs_down = true
      logger.error("REST: OpenMRS REST Query Failed.  URL: #{url} Error: #{e}")
    end

     # Let's see if we got a good result from openmrs

    if !result.nil?  && !$openmrs_down

      doc = JSON.parse(result) if !result.nil?

      unless doc.nil? || doc["results"].length == 0
        $openmrs_down = false

        logger.info("REST: Found #{doc["results"].length} results for mrn_ampath #{mrn_openmrs}")
        # Let's see if we have patient objects for one of the following identifiers.

        # Will just stick with the first patient returned for now
        # If we want the actual patient object, need to grab it from the URI provided
        url = doc["results"][0]["links"][0]["uri"]

        logger.info("REST: Getting patient: #{url}")

        begin
          result = RestClient::Request.execute(:url => url,
                                               :user => OPENMRS_USERNAME,
                                               :password => OPENMRS_PASSWORD,
                                               :method => :get,
                                               :verify_ssl => OpenSSL::SSL::VERIFY_NONE,
                                               :headers => {'Accept' => :json})
        rescue => e
          $openmrs_down = true
          logger.error("REST: OpenMRS REST Query Failed.  URL: #{url} Error: #{e}")
        end

        doc = JSON.parse(result) if !result.nil?

        unless doc.nil?
          person = doc["person"]
          identifiers = doc["identifiers"]

          local_patient_hash = {}
          openmrs_identifiers = {}

          identifiers.each do |i|
            type, mrn = i["display"].split("=")
            [type, mrn].each {|str| str.strip!}
            openmrs_identifiers[type] = mrn
            logger.info("Finding local patient - searching with OpenMRS identifier Type: #{type}, MRN: #{mrn}")
            p = Patient.find_by_mrn_ampath(mrn)
            local_patient_hash[type] = {:patient => p, :mrn => mrn} unless p.nil?
          end

          if local_patient_hash.length == 0
            # We don't have any local patients that match, so create a new patient
            patient = Patient.new
            if openmrs_identifiers.keys.include?(OPENMRS_PREFERRED_IDENTIFIER_TYPE)
              logger.debug("Available Identifiers: #{openmrs_identifiers.inspect}")
              patient.mrn_ampath = openmrs_identifiers[OPENMRS_PREFERRED_IDENTIFIER_TYPE]
            else
              patient.mrn_ampath = openmrs_identifiers.first[1]
            end

            patient.update_via_json(person)
            return patient
          end

          # If we find more than one local patient, then we should merge because OpenMRS
          # has indicated that they are the same person, and is our source of truth

          identifier_types = local_patient_hash.keys

          # Grab the first identifier, that's the patient we will keep in the merge
          first_identifer_type = identifier_types.shift
          first_patient = local_patient_hash[first_identifer_type][:patient]

          if local_patient_hash.length > 1
            identifier_types.each do |key|
              Patient.merge(first_patient, local_patient_hash[key][:patient])
            end
          end

          # Store the configured identifier as the preferred identifier
          # This is done because our system includes one identifier, and OpenMRS can have several

          if local_patient_hash.keys.include?(OPENMRS_PREFERRED_IDENTIFIER_TYPE)
            first_patient.mrn_ampath = local_patient_hash[OPENMRS_PREFERRED_IDENTIFIER_TYPE][:mrn]
            first_patient.save
          end

          # Now we update the other demographics based on the other items in the JSON response
          first_patient.update_via_json(person)
          patient = first_patient
        end

      end
    else
      # The OpenMRS server is down or doesn't know the patient, let's see if we have a local patient
      patient = Patient.find_by_mrn_ampath(mrn_openmrs)
    end

    return patient

  end

  def Patient.merge(p1,p2)

    if p1 == p2
      logger.error ("MERGE: Error - cannot merge the same patient object")
      return
    end

    # This takes two patient objects (p1 and p2) and combines the encounters that
    # belong to p2 into p1 and then deletes the p2 object.

    logger.info ("MERGE: Merging patient #{p2.id}-#{p2.full_name} into #{p1.id}-#{p1.full_name}")

    enc2 = p2.encounters

    enc2.each do |e|
      e.patient_id = p1.id
      e.save!
    end

    p1.save!     # This will make sure that the mrn_ampath gets upcased.

    p2.reload    # This breaks the associations with the already-pulled encounters
    p2.destroy

  end

end
