# If the openmrs.conf.rb file with OpenMRS integration variables exists
# we'll include it here.  If not, turn off OpenMRS integration
if File.exists?('config/openmrs.conf.rb')
  $openmrs = true
  require 'config/openmrs.conf.rb'
else
  $openmrs = false
end

# The following is a sample openmrs.config.rb file.

## config/openmrs.conf.rb
##
## The following constants are used to connect to an openMRS system to retrieve
## patient information.  As a best-practice we should always be using
## https, so that's hard coded.
## Example:
## 
## $openmrs_user = "openmrsuser" 
## $openmrs_password = "openmrspassword" 
## $openmrs_server = "127.0.0.1:8443"
#
#$openmrs_user = "admin"
#$openmrs_password = "test"
#$openmrs_server = "127.0.0.1:8443"