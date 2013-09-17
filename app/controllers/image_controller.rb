class ImageController < ApplicationController
  
  before_filter :authorize_login # Make sure a valid user is logged in.
  before_filter :security, :except => :view # Make sure the current user can modify image data
  
  layout 'ref'
  
  protected
  def security
    
    @current_user = User.find(session[:user_id])
    
    unless @current_user.privilege.modify_encounter
      flash[:notice] = "Not enough privilege to modify images."
      redirect_to :controller => "encounter", :action => "details", :id => params[:encounter_id]
    end 
    
  end

  public
  def view

    # This method is called when the browser needs to display an image.  This is important
    # for security purposes, ensuring that someone is logged in, not just guessing URLs

    @image = Image.find(params[:id])
    @encounter = @image.encounter

    if stale?(:last_modified => @image.updated_at.utc, :etag => @image)
    
      respond_to do |format|

        # Pick which image to send based on the file name submitted in the URL

        format.jpg {send_file(@image.full_image_file, :type => 'image/jpeg', :disposition => 'inline')}
        format.html
        format.xml {render :xml => @image.to_xml}
      end
    end
  end

  def small

    # This method is called when the browser needs to display an image.  This is important
    # for security purposes, ensuring that someone is logged in, not just guessing URLs

    @image = Image.find(params[:id])

    if stale?(:last_modified => @image.updated_at.utc, :etag => @image)

      respond_to do |format|

        # Pick which image to send based on the file name submitted in the URL
        format.jpg {send_file(@image.small_image_file, :type => 'image/jpeg', :disposition => 'inline')}
      end
    end

  end

  def thumb
    # This method is called when the browser needs to display a thumbnail.  This is important
    # for security purposes, ensuring that someone is logged in, not just guessing URLs

    @image = Image.find(params[:id])

    if stale?(:last_modified => @image.updated_at.utc, :etag => @image)
      respond_to do |format|
        format.jpg { send_file(@image.thumb_file, :type => 'image/jpeg', :disposition => 'inline') }
      end
    end
  end
  
  def upload_image
    # Given an encounter, this creates a new image object and links the two.
    @encounter = Encounter.find(params[:id])
    
    @image = Image.new()
    @image.encounter_id = @encounter.id
  end

  def add_image
    # This method is called by the upload_image view, it takes the image data
    # and adds it to the newly created image object

    @image = Image.create(params[:image])

    # Since we now have an image, let's set the encounter status to new so it shows up on the worklist.
    # This will also bring it back on the worklist if a new image is added after the report has been
    # finalized

    @image.encounter.status = "new"
    @image.encounter.save

    flash[:notice] = 'File uploaded'
    redirect_to(:controller => "encounter", :action => 'details', :id => @image.encounter.id)
  end

  def remove_image
    # Destroys an image given an id
    # This is called via AJAX
    
    @image = Image.find(params[:id])
    @image.destroy
  end
  
  def edit_image
    # Finds the image to edit and returns the image and encounter objects
    # to the view

    @image = Image.find(params[:id])
    @encounter = @image.encounter
  end
  
  def rotate
    @image = Image.find(params[:id])
    direction = params[:direction]
    @image.rotate(direction)
    redirect_to(:action => "edit_image", :id => @image)
  end
  
  def crop
    @image = Image.find(params[:id])
    if params[:x1] 
      @image.crop(params[:x1].to_i, params[:y1].to_i, params[:width].to_i, params[:height].to_i)
    else
      flash[:notice] = "No crop selected"
    end
    redirect_to(:action => "edit_image", :id => @image)    
  end
  
end
