#ref.rb
# This is an initializer for all of the application-specific 
# Changes to require.

# Ruby standard library requires
require "digest/md5"
require "net/http"
require "net/https"
require 'rexml/document'

# require 'usermonitor'  # This is a mixin for ActiveRecord that's in /lib

# ActiveRecord::Base.class_eval do
#   include ActiveRecord::UserMonitor
# end

# For the date calendering stuff
# From http://www.methods.co.nz/rails_date_kit/rails_date_kit.html

Date::DATE_FORMATS.merge!(:default => "%Y-%m-%d")

# Specify location where image files are housed
#$image_folder = "#{RAILS_ROOT}/image_archive"

BASEDIRECTORY = Rails.root.join("image_archive")