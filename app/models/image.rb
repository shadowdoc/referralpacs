class Image < ActiveRecord::Base
  require 'RMagick'
  
  belongs_to :encounter

  THUMB_MAX_SIZE = [125,125]
  
  after_save :process
  after_destroy :cleanup
  
  def file_data=(file_data)
    @file_data = file_data
    write_attribute 'extension', file_data.original_filename.split('.').last.downcase
    write_attribute 'path', short_path
  end
    
  def rotate(direction)
    image = Magick::Image.read(image_path).first
    if direction == "right"
      image = image.rotate(90)
    else
      image = image.rotate(-90)
    end
    image.write(image_path)
    create_thumbnail
  end
  
  def crop(x1, y1, width, height)
    image = Magick::Image.read(image_path).first
    image.crop!(x1, y1, width, height) 
    image.write(image_path)
    create_thumbnail
  end

  def change_encounter_date(old_date)
    # Directory names change - file names remain the same


    old_short_path = File.join("#{old_date.year}", "#{old_date.month}", "#{old_date.day}")
    old_image_path = File.join(BASEDIRECTORY, old_short_path, filename)
    old_thumb_path = File.join(BASEDIRECTORY, old_short_path, thumb_filename)
    old_dicom_filename = File.join(BASEDIRECTORY, old_short_path, file_root + ".dcm")
    old_config_filename = File.join(BASEDIRECTORY, old_short_path, file_root + ".cfg")

    create_directory
    
    FileUtils.move(old_image_path, self.image_path) if File.exists?(old_image_path)
    FileUtils.move(old_thumb_path, self.thumb_path) if File.exists?(old_thumb_path)
    FileUtils.move(old_dicom_filename, self.dicom_filename) if File.exists?(old_dicom_filename)
    FileUtils.move(old_config_filename, self.config_filename) if File.exists?(old_config_filename)
  end
  
  def filename(suffix = 'full')
    "#{file_root}-#{suffix}.#{self.extension}"
  end
  
  def file_root
    "#{self.encounter.id}-#{self.id}"
  end
  
  def thumb_filename
    filename('thumb')
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
  
  def image_path
    File.join(BASEDIRECTORY, short_path, filename)
  end
  
  def thumb_path
    File.join(BASEDIRECTORY, short_path, thumb_filename)
  end

  def uuenc_thumb
    "begin 644 #{self.thumb_filename}\n" + [File.open(thumb_path).read].pack("u") + "end"
  end

  def url
    # This method returns the basic URL for an image hosted on our system, or returns the
    # WADO url for an image hosted on dcm4chee

    if self.instance_uid.nil?
      "/image/view/#{self.id}.jpg"
    else
      # We unfortunately have to grab the SeriesUID from the dcm4chee database because our
      # Data model does not include series.

      # This limits the maximum width of the image decreasing bandwidth requirements.
      wado_url_base + "&columns=1750"
    end

  end

  def wado?
    true if instance_uid
  end

  def wado_url_base
    series  = Dcm4cheeInstance.find(self.instance_uid).dcm4chee_series
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

      require 'net/http'

      url = wado_url_base + "&columns=#{THUMB_MAX_SIZE[0]}"

      # Create a URI object from our url string.
      url = URI.parse(url)

      # Create a request object from our url and attach the authorization data.
      req = Net::HTTP::Get.new(url.path + "?" + url.query)

#      Not using authentication - yet.
#      req.basic_auth(OPENMRS_USERNAME, OPENMRS_PASSWORD)

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      begin
        result = http.request(req)

        open(thumb_path, 'wb') do |file|
          file << result.body
        end
      rescue
        puts "dcm4chee wado request failed - #{url}"
      end

    end
  end
  
  def save_fullsize
    File.open(image_path, 'wb') do |file|
      file.puts @file_data.read
    end
  end
  
  def create_directory
    FileUtils.mkdir_p File.join(BASEDIRECTORY,short_path)
  end
  
  def create_thumbnail
    image = Magick::Image.read(image_path).first
    thumbnail = image.thumbnail(*THUMB_MAX_SIZE)
    thumbnail.write thumb_path
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
      result = %x{ #{$jpg2dcm} -C #{config_filename} #{image_path} #{dicom_filename}}
    rescue 
      raise "Dicom save failed: #{result}"
    end
    
  end
  
end