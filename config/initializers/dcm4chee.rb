# Load DCM4CHEE settings from file config/dcm4chee.yml
# Also remember to add the pacsdb settings to config/database.yml

if RAILS_ENV != "test" && File.exists?("#{RAILS_ROOT}/config/dcm4chee.yml")

  settings = YAML::load(File.open("#{RAILS_ROOT}/config/dcm4chee.yml"))

  settings = settings[RAILS_ENV]
  DCM4CHEE_URL_BASE = settings[:url]

else
  # set OPENMRS_SETTINGS to nil
  DCM4CHEE_URL_BASE = nil
end