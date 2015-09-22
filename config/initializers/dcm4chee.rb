# Load DCM4CHEE settings from file config/dcm4chee.yml
# Also remember to add the pacsdb settings to config/database.yml

if (Rails.env.development? || Rails.env.production? || Rails.env.staging?) && File.exists?(Rails.root.join("config/dcm4chee.yml"))

  settings = YAML::load(File.open(Rails.root.join("config/dcm4chee.yml")))

  settings = settings[Rails.env]
  DCM4CHEE_URL_BASE = settings[:url]
  REMOTE_DICOM_PORT = settings[:remote_dicom_port]
  REMOTE_DICOM_HOST = settings[:remote_dicom_host]
  REMOTE_DICOM_AET = settings[:remote_dicom_aet]

  LOCAL_DICOM_PORT = settings[:local_dicom_port]
  LOCAL_DICOM_AET = settings[:local_dicom_aet]

else
  DCM4CHEE_URL_BASE = nil
  LOCAL_DICOM_PORT = nil
end