class Organizer < ActiveRecord::Base
  belongs_to :meeting
  belongs_to :user
  
  attr_accessible :isOrganizer
end