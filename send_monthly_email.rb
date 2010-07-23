patients = Patient.find(:all).length
new = Encounter.find_all_by_status("new").length
ready_for_printing = Encounter.find_all_by_status("ready_for_printing").length
radiologist_to_read = Encounter.find_all_by_status("radiologist_to_read").length
final = Encounter.find_all_by_status("final").length
archived = Encounter.find_all_by_status("archived").length
rejected = Encounter.find_all_by_status("rejected").length
ordered = Encounter.find_all_by_status("ordered").length

StatisticsMailer.deliver_monthly(patients, new, ready_for_printing, radiologist_to_read, final, archived, rejected, ordered)
