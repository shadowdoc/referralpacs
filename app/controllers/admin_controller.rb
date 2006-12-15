class AdminController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @encounter_pages, @encounters = paginate :encounters, :per_page => 10
  end

  def show
    @encounter = Encounter.find(params[:id])
  end

  def new
    @encounter = Encounter.new
  end

  def create
    @encounter = Encounter.new(params[:encounter])
    if @encounter.save
      flash[:notice] = 'Encounter was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @encounter = Encounter.find(params[:id])
  end

  def update
    @encounter = Encounter.find(params[:id])
    if @encounter.update_attributes(params[:encounter])
      flash[:notice] = 'Encounter was successfully updated.'
      redirect_to :action => 'show', :id => @encounter
    else
      render :action => 'edit'
    end
  end

  def destroy
    Encounter.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
   
end
