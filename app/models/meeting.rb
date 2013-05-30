class Meeting < ActiveRecord::Base
  attr_accessible :description, :expectedDuration, :private, :startDate, :title, :token, :user_id
  
  # The User referenced here is the organizer
  belongs_to :user
  
  
  before_save :create_token
  #before_save :check_meeting_time?
  
  VALID_INTEGER_REGEX = /^[1-9]\d*$/
  
  validate :check_meeting_time?
  validates :expectedDuration, :presence => true,:numericality => true
  
  validates :startDate,:presence => true, :numericality => true
  
  validates :title, :presence => true, :length => {:minimum => 4}
  
  
  private 
  def create_token
    self.token = SecureRandom.uuid
  end
  
  def check_meeting_time?
    if !(self.startDate > Time.new.to_i)
      errors.add(:startDate,"can't strat from this time,is greater than #{Time.now.to_i}.")
    end
    if !(self.expectedDuration > 0)
      errors.add(:expectedDuration,"is a invalid duration time,#{Time.at(self.expectedDuration)}.")
    end
  end
  
end
