class Meeting < ActiveRecord::Base
  attr_accessible :description, :expectedDuration, :private, :startDate, :title, :token 
  
  # The User referenced here is the organizer
  belongs_to :user
  
  
  before_save :create_token
  
  VALID_INTEGER_REGEX = /^[1-9]\d*$/
  
  validates :expectedDuration, :presence => true,:numericality => true
  validates :startDate,:presence => true, :numericality => true

  validate :check_meeting_time?
  
  validates :title, :presence => true, :length => {:minimum => 4}
  
  
  private 
  def create_token
    self.token = SecureRandom.uuid
  end
  
  def check_meeting_time?
    if self.startDate == nil
      return false
    end
    if self.expectedDuration == nil
      return false
    end
    if !(self.startDate > DateTime.now)
      errors.add(:startDate,"can't start from this time,is greater than #{DateTime.now}.")
    end
    if !(self.expectedDuration > 0)
      errors.add(:expectedDuration,"is a invalid duration time,#{Time.at(self.expectedDuration)}.")
    end
  end
  
end
