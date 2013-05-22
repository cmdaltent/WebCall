class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  before_filter :check_session
  private 
  
  def check_session
    #flash[:success]="Session Checked"
    #if the session is empty or dosen't equal to the current_user, sign out and redirect to the signin pages. 
  end
  
end
