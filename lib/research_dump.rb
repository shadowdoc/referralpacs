# This file is meant to be run by ruby script/runner
# This runs through the entire database and prepares a research data set
# comprised of images that have de-identified IDs and XML documents recording
# the observations for that specific patient.

# The images will have to be de-identified separately if they have PHI
# saved as part of the image

# We will be writing files to BASEDIRECTORY/research

# Let's find encounters with observations, which should be in status final

require "digest/md5"

encounter_list = Encounter.find_all_by_status("final")

encounter_list.each do |enc|

  image_list = enc.images

  # First we'll copy the image to the new directory with a new filename.

  image_list.each do |i|

    existing_jpg_file  = File.join(BASEDIRECTORY, i.short_path, i.filename)

    # We will use a one-way hexdigest to obscure the short filename.

    new_file_root = Digest::MD5.hexdigest(i.file_root)

    # Create new directory
    new_path = File.join(BASEDIRECTORY, "research", i.short_path)
    FileUtils.mkdir_p(new_path)

    new_jpg_filename = new_file_root + ".jpg"

    new_xml_filename = new_file_root + ".csv"

    puts "Processing #{i.filename} into #{new_jpg_filename}\n"

    FileUtils.copy(existing_jpg_file, File.join(new_path, new_jpg_filename))

    # Now, let's dump the observations for this encounter to an .csv file
    File.open(File.join(new_path, new_xml_filename), 'wb') do |file|
      obs_list = enc.observations
      obs_list.each do |o|
        file.puts "#{o.question_concept.id},#{o.question_concept.name},#{o.value_concept.id},#{o.value_concept.name},#{o.openmrs_id}"
      end
    end

  end

end


