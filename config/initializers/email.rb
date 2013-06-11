# Load mail configuration if not in test environment
if RAILS_ENV != 'test'  && File.exists?("#{RAILS_ROOT}/config/email.yml")
  # This loads configuration settings for the monthly statistics e-mails
  # All of the settings except for recipients are the basic smtp settings
  # We assign the recipeints to a global constant and then remove it from the
  # hash that we pass to ActionMailer

  email_settings = YAML::load(File.open("#{RAILS_ROOT}/config/email.yml"))

  STATISTICS_EMAIL_LIST = email_settings[RAILS_ENV].delete(:recipients)

  ActionMailer::Base.smtp_settings = email_settings[RAILS_ENV] unless email_settings[RAILS_ENV].nil?
end

