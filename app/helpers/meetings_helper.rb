module MeetingsHelper
  
  def meeting_of_user
    @userid = User.find_by_id(cookies[:id]).id
    @meetingid ||= Meeting.find_by_user_id(@userid)
  end
  
  def is_meetings_user?
    !meetingid.nil?
  end
  
end
