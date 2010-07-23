class StatisticsMailer < ActionMailer::Base
  def monthly(begin_time, end_time, local_recipients, active_providers, patients, new, ready_for_printing, radiologist_to_read, final, archived, rejected, ordered, sent_at = Time.now)
    subject	"ReferralPACS Statistics"
    body	:begin_time => begin_time, :end_time => end_time, :active_providers => active_providers, :patients => patients, :new => new, :ready_for_printing => ready_for_printing, :final => final, :archived => archived, :rejected => rejected, :ordered => ordered
    recipients local_recipients
    from	["mkohli@iupui.edu"]
    sent_on	sent_at
  end
end
