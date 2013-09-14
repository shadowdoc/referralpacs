# Load DCM4CHEE settings from file config/dcm4chee.yml
# Also remember to add the pacsdb settings to config/database.yml

if (Rails.env.development? || Rails.env.production?) && File.exists?(Rails.root.join("config/dcm4chee.yml"))

  settings = YAML::load(File.open(Rails.root.join("config/dcm4chee.yml")))

  settings = settings[Rails.env]
  DCM4CHEE_URL_BASE = settings[:url]

else
  # set OPENMRS_SETTINGS to nil
  DCM4CHEE_URL_BASE = nil
end