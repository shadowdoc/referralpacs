begin_time = Time.now.midnight - 1.month
end_time = Time.now.midnight

patients = Patient.count
new = Encounter.find_all_by_status("new").length
ready_for_printing = Encounter.find_all_by_status("ready_for_printing").length
radiologist_to_read = Encounter.find_all_by_status("radiologist_to_read").length
final = Encounter.find_all_by_status("final").length
archived = Encounter.find_all_by_status("archived").length
rejected = Encounter.find_all_by_status("rejected").length
ordered = Encounter.find_all_by_status("ordered").length

monthly_encounters = Encounter.all(:conditions => {:updated_at => begin_time..end_time}, :include => :provider)

active_providers = Hash.new

monthly_encounters.each do |enc|
  
  # Let's create an hash of providers who have read exams over the last month

  if enc.status == "final" || enc.status == "ready_for_printing"
    unless active_providers.key?(enc.provider.full_name)
      active_providers[enc.provider.full_name] = 1
    else
      active_providers[enc.provider.full_name] += 1
    end
  end
end

StatisticsMailer.deliver_monthly(begin_time, end_time, active_providers, patients, new, ready_for_printing, radiologist_to_read, final, archived, rejected, ordered)
