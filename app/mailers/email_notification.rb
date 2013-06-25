class EmailNotification < ActionMailer::Base
  default :from => "no-replay@kpwebcall.com", :content_type => "text/html" 
  
  def meeting_notification(recipient, meeting, sent_at = Time.now)
    mail(:bcc => recipient, :subject => "KP WebCall – meeting invitation", :body => meeting.token.to_s)
  end
end
