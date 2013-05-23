class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  before_filter :check_session
  private 
  
  def check_session
    unless signedin?
      flash[:success]="Session is checked here."
      #redirect_to signin_path
    end
  end
  
end
