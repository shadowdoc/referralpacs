require File.dirname(__FILE__) + '/../test_helper'
require 'image_controller'

# Re-raise errors caught by the controller.
class ImageController; def rescue_action(e) raise e end; end

class ImageControllerTest < Test::Unit::TestCase
  
  fixtures :users, :encounters
  
  def setup
    @controller = ImageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_upload_images
    
    assert 1, Image.count
    
    get(:upload_image,
       {:id => encounters(:chest_pain)},
       {:user_id => users(:tech).id})
    
    img = uploaded_jpeg("#{File.expand_path(RAILS_ROOT)}/test/fixtures/rails.jpg")
    
    post(:add_image,
        {:image => {:file_data => img,
                    :encounter_id => encounters(:chest_pain).id}},
        {:user_id => users(:tech).id})

    assert_redirected_to :action => "show"
    
    assert 2, Image.count
    
    #Now, test removing the same image
    
    post(:remove_image,
        {:id => 3},
        {:user_id => users(:tech).id})
        
    assert 1, Image.count
    
  end
  
  # Helpers to simulate file uploads.  Stolen from: http://manuals.rubyonrails.com/read/chapter/28
  # get us an object that represents an uploaded file
  
  def uploaded_file(path, content_type="application/octet-stream", filename=nil)
    filename ||= File.basename(path)
    t = Tempfile.new(filename)
    FileUtils.copy_file(path, t.path)
    (class << t; self; end;).class_eval do
      alias local_path path
      define_method(:original_filename) { filename }
      define_method(:content_type) { content_type }
    end
    return t
  end
  
  # a JPEG helper
  def uploaded_jpeg(path, filename=nil)
    uploaded_file(path, 'image/jpeg', filename)
  end
  
  # a GIF helper
  def uploaded_gif(path, filename=nil)
    uploaded_file(path, 'image/gif', filename)
  end

end
