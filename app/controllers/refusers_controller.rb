class RefusersController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @refusers_pages, @refusers = paginate :refusers, :per_page => 10
  end

  def show
    @refusers = Refusers.find(params[:id])
  end

  def new
    @refusers = Refusers.new
  end

  def create
    @refusers = Refusers.new(params[:refusers])
    if @refusers.save
      flash[:notice] = 'Refusers was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @refusers = Refusers.find(params[:id])
  end

  def update
    @refusers = Refusers.find(params[:id])
    if @refusers.update_attributes(params[:refusers])
      flash[:notice] = 'Refusers was successfully updated.'
      redirect_to :action => 'show', :id => @refusers
    else
      render :action => 'edit'
    end
  end

  def destroy
    Refusers.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
