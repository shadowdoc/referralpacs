# This file should be run from within ruby script/runner
# It queries the dcm4chee archive for studies that have a study_status of 0
# Which indicates that they are new.

dcm_studies = Dcm4cheeStudy.find_all_by_study_status(0)
enc_controller = EncounterController.new


# Loop through all of the images that have been added to the repository.

dcm_studies.each do |dcm_study|

  enc_controller.new_dcm4chee(dcm_study)
end
