class User < ActiveRecord::Base
  attr_accessible :e_mail, :first_name, :last_name, :token, :username
  
  # Meetings referenced here where scheduled by the User
  # The User is the organizer of the referenced meetings here
  has_many :meetings, :dependent => destroy
end
