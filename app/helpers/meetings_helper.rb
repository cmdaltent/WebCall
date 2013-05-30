module MeetingsHelper
  
  def inMeeting?
    @userid = User.find_by_id(cookies[:id]).id
    if Meeting.find_by_user_id(@userid) != nil
      return true
    else
      return false
    end
  end
  
end
