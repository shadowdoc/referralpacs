class StatisticsMailer < ActionMailer::Base
  def monthly(patients, new, ready_for_printing, radiologist_to_read, final, archived, rejected, ordered, sent_at = Time.now)
    subject	"ReferralPACS Statistics"
    body	:patients => patients, :new => new, :ready_for_printing => ready_for_printing, :final => final, :archived => archived, :rejected => rejected, :ordered => ordered
#    recipients	["mkohli@iupui.edu", "abuyajm@yahoo.com", "matjohns@iupui.edu", "wanenegl@yahoo.com", "kelvin.ogot@gmail.com"]
    recipients ["mkohli@iupui.edu"]
    from	["mkohli@iupui.edu"]
    sent_on	sent_at
  end
end
