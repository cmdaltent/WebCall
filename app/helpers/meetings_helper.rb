module MeetingsHelper
  
  def inMeeting?
    # user = User.find_by_id(cookies[:token])
    # if Meeting.find_by_user_id(@userid) != nil
    if !current_user.meetings.empty?
      return true
    else
      return false
    end
  end
  
end
