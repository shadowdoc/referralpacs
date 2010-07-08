# Load OpenMRS settings from file config/openmrs.yml
if RAILS_ENV != "test" && File.exists?("#{RAILS_ROOT}/config/openmrs.yml")

  settings = YAML::load(File.open("#{RAILS_ROOT}/config/openmrs.yml"))

  settings = settings[RAILS_ENV]
  OPENMRS_URL_BASE = settings["url"]
  OPENMRS_USERNAME = settings["username"]
  OPENMRS_PASSWORD = settings["password"]
else
  # set OPENMRS_SETTINGS to nil
  OPENMRS_URL_BASE = nil
end