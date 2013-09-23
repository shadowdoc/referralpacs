class QualityController < ApplicationController
  layout "ref"
  before_filter :authorize_login
  before_filter :security

  protected
  def security
    # This method is called before data modifying actions to make sure the user
    # has the ability to modify encounters
    @current_user = User.find(session[:user_id])

    unless @current_user.privilege.quality_control
      flash[:notice] = "No access to Quality Control"
      redirect_to :controller => "patient", :action => "find"
    end
  end

  public
  def list
    #Find all quality checks that are marked "for list"
    @checks = QualityCheck.where("status = ? && provider_id != ?", 'for_review', @current_user.id)
  end

  def review
    @check = QualityCheck.find(params[:id])
    @check.reviewer = User.find(session[:user_id])

    if request.post?
      # Here we update the QualityCheck with the parameters from the browser.
      @check.score = params[:check][:score]
      @check.status = "reviewed"
      @check.comment = params[:check][:text]
      @check.save
      redirect_to :action => :list
    end

  end

  def stats

    @provider_quality_summary = []

    Provider.all.each do |provider|
      provider_array = []

      ["1", "2a", "2b", "3a", "3b", "4a", "4b"].each do |score|

        checks = QualityCheck.where("provider_id = ? && score = ?", provider.id, score)

        provider_array << {score => checks.length}
      end

      @provider_quality_summary << {provider.full_name => provider_array}
    end

  end
end
