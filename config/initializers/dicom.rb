# If the openmrs.conf.rb file with OpenMRS integration variables exists
# we'll include it here.  If not, turn off OpenMRS integration
if File.exists?('config/dicom.conf.rb')
  $dicom = true
  require 'config/dicom.conf.rb'
else
  $dicom = false
end

## config/dicom.conf.rb
##
## The following constants are used to identify the dcm4che utilities that
## are used to create DICOM images and send to a DICOM server.
## 
## Example:
## 
## $AETITLE = "osirix-kohli" 
## $dicom_server = "192.168.242.1"
## $dicom_port = "104"
## Specify the location of the jpg2dcm program
## $jpg2dcm = "/home/rifellow/dcm4che-2.0.18/bin/jpg2dcm"
# $jpg2dcm = "/home/rifellow/dcm4che-2.0.18/bin/jpg2dcm"
# $AETITLE = "osirix-kohli" 
# $dicom_server = "192.168.242.1"
# $dicom_port = "104" 