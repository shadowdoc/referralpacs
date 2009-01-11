class ImageController < ApplicationController
  
  before_filter :authorize_login # Make sure a valid user is logged in.
  before_filter :security, :except => :view # Make sure the current user can modify image data
  
  layout 'ref'
  
  protected
  def security
    
    @current_user = User.find(session[:user_id])
    
    unless @current_user.privilege.modify_encounter
      flash[:notice] = "Not enough privilege to modify images."
      return(redirect_to :controller => "encounter", :action => "details", :id => params[:encounter_id])
    end 
    
  end

  public
  def view
    @image = Image.find(params[:id])
    @encounter = @image.encounter
    
    respond_to do |format|
      format.jpg {send_file(@image.full_path, :type => 'image/jpeg', :disposition => 'inline')}
      format.html
      format.xml {render :xml => @image.to_xml}
    end

  end
  
  def thumb
    @image = Image.find(params[:id])
    respond_to do |format|
      format.jpg { send_file(@image.thumb_path, :type => 'image/jpeg', :disposition => 'inline') }
    end
  end
  
  def upload_image
      
    # Given an encounter, this creates a new image object and links the two.
    @encounter = Encounter.find(params[:id])
    
    @image = Image.new()
    @image.encounter_id = @encounter.id
  end

  def add_image  
    @image = Image.create(params[:image])
    flash[:notice] = 'File uploaded'
    redirect_to(:controller => "encounter", :action => 'details', :id => @image.encounter.id)
  end
  
  def remove_image
    # Destroys an image given an id
    
    @image = Image.find(params[:id])
    @image.destroy
    render :update do |page|
      page.remove "thumbnail-#{params[:id]}"
    end
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
