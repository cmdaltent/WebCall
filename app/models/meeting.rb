class Meeting < ActiveRecord::Base
  attr_accessible :description, :expectedDuration, :private, :startDate, :title, :token
  
  # The User referenced here is the organizer
  belongs_to :user
end
