# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Ref::Application.initialize!


if DICOM_LOCAL_PORT
	s = DICOM::DServer.new(DICOM_LOCAL_PORT, :host_ae => DICOM_LOCAL_AET)
	t = Thread.new { s.start_scp("./public/dicom/") }
end