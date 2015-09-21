# Load DCM4CHEE settings from file config/dcm4chee.yml
# Also remember to add the pacsdb settings to config/database.yml

if (Rails.env.development? || Rails.env.production? || Rails.env.staging?) && File.exists?(Rails.root.join("config/dcm4chee.yml"))

  settings = YAML::load(File.open(Rails.root.join("config/dcm4chee.yml")))

  settings = settings[Rails.env]
  DCM4CHEE_URL_BASE = settings[:url]
  DCM4CHEE_REMOTE_PORT = settings[:remote_dicom_port]
  DCM4CHEE_REMOTE_HOST = settings[:remote_dicom_host]
  DCM4CHEE_REMOTE_AET = settings[:remote_dicom_aet]

  DICOM_LOCAL_PORT = settings[:local_dicom_port]
  DICOM_LOCAL_AET = settings[:local_dicom_aet]

else
  DCM4CHEE_URL_BASE = nil
  DICOM_LOCAL_PORT = nil
end