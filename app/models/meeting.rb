class Meeting < ActiveRecord::Base
  attr_accessible :description, :expectedDuration, :private, :startDate, :title, :token
  
  # The User referenced here is the organizer
  belongs_to :user
  
  
  before_save :create_token
  
  VALID_INTEGER_REGEX = /^[1-9]\d*$/
  
  validates :expectedDuration, :presence => true,:numericality => true
  
  validates :startDate,:presence => true, :numericality => true
  
  validates :title, :presence => true, :length => {:minimum => 4}
  
  
  private 
  def create_token
    self.token = SecureRandom.uuid
  end
end
