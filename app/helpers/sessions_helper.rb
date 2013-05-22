module SessionsHelper
  def sign_in(user)
    #cookies.permanent[:token] = [name:user.username,psw:user.password]
    cookies[:id] = user.id
    self.current_user = user
  end
  
  def current_user=(user)
    @current_user = user
  end
  
  def current_user
    @current_user ||=User.find_by_id(cookies[:id])
  end
  
  def signin?
    !current_user.nil?
  end
  
  def signout
    self.current_user = nil
    #cookies.delete(:token)
    cookies.delete(:id)
  end
  
end
