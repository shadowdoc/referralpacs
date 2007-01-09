class Image < ActiveRecord::Base

  belongs_to :encounter

  BASEDIRECTORY = 'public/image_test'
  THUMB_MAX_SIZE = [125,125]
  
  after_save :process
  after_destroy :cleanup
  
  def file_data=(file_data)
    @file_data = file_data
    write_attribute 'extension', file_data.original_filename.split('.').last.downcase
    write_attribute 'path', short_path
  end
  
  def eid=(eid)
    @eid = eid
    write_attribute 'encounter_id', eid
  end
  
  def full_path
    File.join(BASEDIRECTORY, short_path, filename)
  end
  
  def thumb_path
    File.join (BASEDIRECTORY, short_path, thumb_filename)
  end
  
  def filename(ext = 'full')
    "#{self.encounter.id}-#{self.id}-#{ext}.#{extension}"
  end
  
  def thumb_filename
    filename('thumb')
  end
  
  def all_versions_path
    
  end
  
  def short_path
    File.join("#{self.encounter.date.year()}", "#{self.encounter.date.month()}", "#{self.encounter.date.day()}")
  end
  
  private
  
  def process
    if @file_data
      create_directory
      cleanup
      save_fullsize
      @file_data = nil
    end
  end
  
  def save_fullsize
    File.open(full_path, 'wb') do |file|
      file.puts @file_data.read
    end
  end
  
  def create_directory
    FileUtils.mkdir_p File.join(BASEDIRECTORY,short_path)
  end
  
  def create_thumbnail
    image = Magick::Image.read(full_path)
  end
  
  def cleanup
    Dir[full_path].each do |filename|
      File.unlink(filename) rescue nil
    end
  end

end
