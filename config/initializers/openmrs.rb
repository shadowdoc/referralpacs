# Load OpenMRS settings from file config/openmrs.yml
if (Rails.env.development? || Rails.env.production?) && File.exists?(Rails.root.join("config/openmrs.yml"))

  settings = YAML::load(File.open(Rails.root.join("config/openmrs.yml")))

  settings = settings[Rails.env]
  OPENMRS_URL_BASE = settings[:url]
  OPENMRS_HL7_URL = settings[:hl7_url]
  OPENMRS_USERNAME = settings[:username]
  OPENMRS_PASSWORD = settings[:password]
  OPENMRS_HL7_PATH = settings[:hl7path]
  OPENMRS_HL7_REST = settings[:hl7rest]
  OPENMRS_SENDING_FACILITY = settings[:hl7sending_facility]
  OPENMRS_RECV_FACILITY = settings[:hl7recv_facility]
  OPENMRS_PREFERRED_IDENTIFIER_TYPE = settings[:preferred_identifier_type]

  if OPENMRS_HL7_PATH
    FileUtils.mkdir_p(Rails.root.join(OPENMRS_HL7_PATH, "queue"))
  end

else
  # set OPENMRS_SETTINGS to nil
  OPENMRS_URL_BASE = nil
end