# Load mail configuration if not in test environment
if (Rails.env.development? || Rails.env.production?)  && File.exists?(Rails.root.join("/config/email.yml"))
  # This loads configuration settings for the monthly statistics e-mails
  # All of the settings except for recipients are the basic smtp settings
  # We assign the recipeints to a global constant and then remove it from the
  # hash that we pass to ActionMailer

  email_settings = YAML::load(File.open(Rails.root.join("/config/email.yml")))

  STATISTICS_EMAIL_LIST = email_settings[Rails.env].delete(:recipients)

  ActionMailer::Base.smtp_settings = email_settings[Rails.env] unless email_settings[Rails.env].nil?
end