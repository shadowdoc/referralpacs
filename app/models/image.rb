class Image < ActiveRecord::Base

  attr_accessible :encounter_id, :file_data
  
  belongs_to :encounter

  THUMB_MAX_SIZE = '125'
  SMALL_IMAGE_WIDTH = '1250'
  
  after_save :process
  after_destroy :cleanup
  
  def file_data=(file_data)
    @file_data = file_data
    write_attribute 'extension', file_data.original_filename.split('.').last.downcase
    write_attribute 'path', short_path
  end
    
  def rotate(direction)
    image = MiniMagick::Image.open(full_image_file)
    if direction == "right"
      image = image.rotate(90)
    else
      image = image.rotate(-90)
    end
    image.write(full_image_file)
    create_thumbnail
  end
  
  def crop(x1, y1, width, height)
    image = MiniMagick::Image.open(full_image_file)
    image.crop("#{x1}x#{y1}+#{width}+#{height}")
    image.write(full_image_file)
    create_thumbnail
  end

  def change_encounter_date(old_date)
    # Directory names change - file names remain the same
    old_short_path = File.join("#{old_date.year}", "#{old_date.month}", "#{old_date.day}")
    old_image_path = File.join(BASEDIRECTORY, old_short_path, filename)
    old_thumb_path = File.join(BASEDIRECTORY, old_short_path, file_root + '-thumb' + self.extension)
    old_dicom_filename = File.join(BASEDIRECTORY, old_short_path, file_root + ".dcm")
    old_config_filename = File.join(BASEDIRECTORY, old_short_path, file_root + ".cfg")

    create_directory
    
    FileUtils.move(old_image_path, self.full_image_file) if File.exists?(old_image_path)
    FileUtils.move(old_thumb_path, self.thumb_file) if File.exists?(old_thumb_path)
    FileUtils.move(old_dicom_filename, self.dicom_filename) if File.exists?(old_dicom_filename)
    FileUtils.move(old_config_filename, self.config_filename) if File.exists?(old_config_filename)
  end
  
  def filename(suffix = 'full')
    "#{file_root}-#{suffix}.#{self.extension}"
  end
  
  def file_root
    "#{self.encounter.id}-#{self.id}"
  end
  
  def all_versions_path
    allversions = filename('*')
    File.join(short_path, allversions)
  end
  
  def short_path
    unless self.encounter.nil?
      File.join("#{self.encounter.date.year()}", "#{self.encounter.date.month}", "#{self.encounter.date.day}")
    end
  end
  
  def config_filename
    File.join(BASEDIRECTORY, short_path, file_root + ".cfg")
  end
  
  def dicom_filename
    File.join(BASEDIRECTORY, file_root + ".dcm")
  end
  
  def full_image_file
    File.join(BASEDIRECTORY, short_path, filename)
  end

  def small_image_file
    File.join(BASEDIRECTORY, short_path, file_root + '-small.' + self.extension)
  end

  def thumb_file
    File.join(BASEDIRECTORY, short_path, file_root + '-thumb.' + self.extension)
  end

  def uuenc_thumb
    "begin 644 #{file_root + '-thumb' + self.extension}\n" + [File.open(thumb_file).read].pack("u") + "end"
  end

  def url
    # This method returns the basic URL for an image hosted on our system, or returns the
    # WADO url for an image hosted on dcm4chee

    if !wado?
      # This means that we have a digital camera (local) jpg

      if SMALL_IMAGE_WIDTH
        # If DEFAULT_IMAGE_WIDTH is set then we need to check if we have a resized version stored
        if !File.exists?(small_image_file)
          # The small version does not exist.  We need to create it first
          create_small
        end
        "/image/small/#{self.id}.jpg"
      else
        "/image/view/#{self.id}.jpg"
      end
    else
      # Here is where we find the wado URL

      # This limits the maximum width of the image decreasing bandwidth requirements.
      wado_url_base + "&columns=#{SMALL_IMAGE_WIDTH}"
    end

  end

  def wado?
    true if instance_uid
  end

  def wado_url_base
    # We have to grab the SeriesUID for a complete wado request.
    series  = Dcm4cheeInstance.find_by_sop_iuid(self.instance_uid).dcm4chee_series
    DCM4CHEE_URL_BASE + "wado?requestType=WADO&studyUID=#{self.encounter.study_uid}&seriesUID=#{series.series_iuid}&objectUID=#{self.instance_uid}"
  end

  private
  
  def process
    if @file_data
      # This is an digital camera image uploaded from a browser
      create_directory
      cleanup
      save_fullsize
      create_thumbnail
      if $jpg2dcm != ""
        create_dicom_config
        create_dicom
      end
      @file_data = nil
    end

    if wado?
      # We have a wado image.  Let's grab the local thumbnail and save it
      create_directory
      write_attribute 'path', short_path

      url = wado_url_base + "&columns=#{THUMB_MAX_SIZE}"

      # Create a URI object from our url string.
      url = URI.parse(url)

      # Create a request object from our url and attach the authorization data.
      req = Net::HTTP::Get.new(url.path + "?" + url.query)

      http = Net::HTTP.new(url.host, url.port)

      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl = true

      begin
        result = http.request(req)

        open(thumb_file, 'wb') do |file|
          file << result.body
        end
      rescue
        failed = true
      end

      if result.code != "200" || failed
        logger.error("dcm4chee wado request failed - #{url}.  Result: #{result}")
      end

    end
  end
  
  def save_fullsize
    File.open(full_image_file, 'wb') do |file|
      file.puts @file_data.read
    end
  end
  
  def create_directory
    FileUtils.mkdir_p File.join(BASEDIRECTORY,short_path)
  end

  def create_small
    image = resize(SMALL_IMAGE_WIDTH)
    image.write(small_image_file)
  end
  
  def create_thumbnail
    image = resize(THUMB_MAX_SIZE)
    image.write(thumb_file)
  end

  def resize(width)
    # This method creates a new image object from the original file using
    # The adaptive_resize method.
    image = MiniMagick::Image.open(full_image_file)
    image.adaptive_resize(width)
    image
  end
  
  def cleanup
    Dir[all_versions_path].each do |filename|
      File.unlink(filename) rescue nil
    end
  end
  
  def create_dicom_config
    # This method creates the configuration file that contains all of the necessary patient
    # demographic data and then runs the external jpg2dcm program to create a dicom image
    
    # Write the configuration file
    patient = self.encounter.patient
    encounter = self.encounter
    File.open(config_filename, 'wb') do |file|
      file.puts "
# Patient Module Attributes
# Patient's Name
00100010:#{patient.dicom_name}
# Patient ID 
00100020:#{patient.mrn_ampath}
# Issuer of Patient ID
00100021:AMPATH
# Patient's Birth Date
00100030:#{patient.dicom_birthday}
# Patient's Sex
00100040:#{patient.hl7_sex}

# General Study Module Attributes
# Study Instance UID
#0020000D:
# Study Date
00080020:#{encounter.date.strftime('%Y%m%d')}
# Study Time
00080030:#{encounter.date.strftime('%H%M%S')}
# Referring Physician's Name
00080090:#{encounter.client.hl7_name}
# Study ID
00200010:
# Accession Number
00080050:#{encounter.id}
# Study Description
#00081030:#{encounter.encounter_type.name}

# General Series Module Attributes
# Modality
00080060:CR
# Series Instance UID
#0020,000E:
# Series Number
00200011:1

# SOP Common Module Attributes
# SOP Class UID
00080016:1.2.840.10008.5.1.4.1.1.7
# SOP Instance UID
#00080018"
    end
  end

  def create_dicom  
    
    begin
      result = %x{ #{$jpg2dcm} -C #{config_filename} #{full_image_file} #{dicom_filename}}
    rescue 
      raise "Dicom save failed: #{result}"
    end
    
  end
  
end
