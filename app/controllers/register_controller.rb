class RegisterController < ApplicationController
  require 'railspdf'
  layout 'ref'

  def report
    if request.get? || params[:report][:start_date].nil? || params[:report][:end_date].nil?
      render(:template => "register/report_form.rhtml")
    else
      @encounters = Encounter.find(:all, :conditions => ['date between ? and ?', params[:report][:start_date], params[:report][:end_date]])
      if @encounters.length == 0
        flash[:notice] = "No encounters for that date range, please try again."
        render(:template => "register/report_form.rhtml")
      else
        render(:layout => false)
      end
    end
  end
end
