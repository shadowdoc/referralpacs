# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Ref::Application.initialize!


if LOCAL_DICOM_PORT
	s = DICOM::DServer.new(LOCAL_DICOM_PORT, :host_ae => LOCAL_DICOM_AET)
	t = Thread.new { s.start_scp("./image_archive/dicom/") }
end