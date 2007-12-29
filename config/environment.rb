# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_ref_session',
    :secret      => 'jieu566kejh49947g4gh4j9g99ll1032uncdbo1094ygfbl3o3urhbpoe409383hbfhn1294856jak38tyg3jo3857nbzskwijtjhkwjkeut978392128565g1jk590a'
                    
  }

end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below
require 'usermonitor'
ActiveRecord::Base.class_eval do
  include ActiveRecord::UserMonitor
end

# For the date calendering stuff
# From http://www.methods.co.nz/rails_date_kit/rails_date_kit.html

ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(
  :default => '%Y-%m-%d'
)

# Requried to use railspdf and .rpdf views , currently used by registrars
# to generate reports.
#gem 'pdf-writer'
gem 'pdf-writer'

# We need to protect our image files from people 
# URL hacking, so we need to have the controller handle each file
# This will use respond_to which requires knowlege of the "image/jpeg" MIME type.
Mime::Type.register("image/jpeg", :jpg)


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
## $openmrs_server = "127.0.0.1:8080"
#
#$openmrs_user = "admin"
#$openmrs_password = "test"
#$openmrs_server = "127.0.0.1:8443"