module SessionsHelper
  
  def login
    @current_user = User.find_by_username_and_by_passworddigest(params[:username],params[:password_digest])
    if current_user
      session[:user_id] = current_user.id
      puts :user_id
      redirect_to :action => 'index'
    else
      reset_session
      flash[:note] = "invalid user or password"
    end
  end

  
  def sign_in(user)
    #cookies.permanent[:token] = [name:user.username,psw:user.password]
    cookies[:token] = user.token
    # session[:user_id] = user.id
    self.current_user = user
  end
  
  def current_user=(user)
    @current_user = user
  end
  
  def current_user
    @current_user ||=User.find_by_token(cookies[:token])
  end
  
  def signin?
    !current_user.nil?
  end
  
  def signout
    self.current_user = nil
    cookies.delete :token
  end
  
  
  
end
