class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticated_user,only:[:home]
  
  def home
  end
  
  include SessionsHelper
  
  private
    def authenticated_user
    unless signin?
      redirect_to signin_path,notice: "Please sign in." 
    end
  end
  
end