class StatisticsMailer < ActionMailer::Base
  default :from => "mkohli@iu.edu"

  def monthly(begin_time, end_time, local_recipients, active_providers, patients, new, ready_for_printing, radiologist_to_read, final, archived, rejected, ordered, sent_at = Time.now)
    mail(:subject => "ReferralPACS Statistics",
    	 :date => sent_at,
    	 :body => body,
    	 :begin_time => begin_time,
    	 :end_time => end_time, 
    	 :active_providers => active_providers, 
    	 :patients => patients, 
    	 :new => new, 
    	 :ready_for_printing => ready_for_printing, 
    	 :final => final, 
    	 :archived => archived, 
    	 :rejected => rejected, 
    	 :ordered => ordered,
    	 :to => local_recipients)
  end
end