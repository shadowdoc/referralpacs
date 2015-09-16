class StatisticsMailer < ActionMailer::Base
  default :from => "mkohli@iu.edu"

  def monthly
    # This mailing defaults to 1 month of activity.

    recipients = STATISTICS_EMAIL_LIST

    @begin_time = Time.now.midnight - 1.month
    @end_time = Time.now.midnight

    @patients = Patient.count

    @stat_hash = Encounter.group(:status).count

    @new = Encounter.where(status: "new").count

    @active_providers = Encounter.includes(:provider).group(:provider).where(:updated_at => @begin_time..@end_time).count

    mail(:subject => "ReferralPACS Statistics",
    	 :date => Time.now,
    	 :to => STATISTICS_EMAIL_LIST,
       :content_type => "text/plain")
  end
end