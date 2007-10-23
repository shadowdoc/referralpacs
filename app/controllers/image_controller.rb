class ImageController < ApplicationController
  
  def upload_image
    # Given an encounter, this creates a new image object and links the two.

    @encounter = Encounter.find(params[:id])
    @image = Image.new()
    @image.encounter_id = @encounter.id
  end

  def add_image  
    @image = Image.create(params[:image])
    flash[:notice] = 'File uploaded'
    redirect_to(:controller => "encounter", :action => 'show', :id => @image.encounter.id)
  end
  
  def remove_image

    @image = Image.find(params[:id])
    @encounter = @image.encounter
    @image.destroy
    render :update do |page|
      page.remove "thumbnail-#{params[:id]}"
    end
  end
  
  def view_image
  
    @image = Image.find(params[:id])
    @encounter = @image.encounter
  end
  
  def edit_image
  
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
