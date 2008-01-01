class Image < ActiveRecord::Base
  require 'RMagick'
  
  belongs_to :encounter

  BASEDIRECTORY = "#{RAILS_ROOT}/image_archive"
  THUMB_MAX_SIZE = [125,125]
  
#  This is depricated after moving the images out of the reach of the 
#  Web server and link hackers  
#  LINKDIRECTORY = "/system/image_archive"  
  
  after_save :process
  after_destroy :cleanup
  
  def file_data=(file_data)
    @file_data = file_data
    write_attribute 'extension', file_data.original_filename.split('.').last.downcase
    write_attribute 'path', short_path
  end
    
  def rotate(direction)
    image = Magick::Image.read(full_path).first
    if direction == "right"
      image = image.rotate(90)
    else
      image = image.rotate(-90)
    end
    image.write(full_path)
    create_thumbnail
  end
  
  def crop(x1, y1, width, height)
    image = Magick::Image.read(full_path).first
    image.crop!(x1, y1, width, height) 
    image.write(full_path)
    create_thumbnail
  end
    
  def full_path
    File.join(BASEDIRECTORY, short_path, filename)
  end
  
  def thumb_path
    File.join(BASEDIRECTORY, short_path, thumb_filename)
  end  
  
  def filename(suffix = 'full')
    "#{self.encounter.id}-#{self.id}-#{suffix}.#{self.extension}"
  end
  
  def thumb_filename
    filename('thumb')
  end
  
  def thumb_url
    thumb_path.sub(/^public/,'')
  end
  
  def full_url
    full_path.sub(/^public/,'')
  end
  
  def all_versions_path
    allversions = filename('*')
    File.join(BASEDIRECTORY, short_path, allversions)
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
      create_thumbnail
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
    image = Magick::Image.read(full_path).first
    thumbnail = image.thumbnail(*THUMB_MAX_SIZE)
    thumbnail.write thumb_path
  end
  
  def cleanup
    Dir[all_versions_path].each do |filename|
      File.unlink(filename) rescue nil
    end
  end

#  FIXME - Remove these methods once it's clear they are not in use. 
#  These methods should not be in use any longer as we have plugged that security hole.
#  def link_path
#    File.join(LINKDIRECTORY, short_path, filename)
#  end
#  
#  def link_thumb_path
#    File.join(LINKDIRECTORY, short_path, thumb_filename)
#  end

end
