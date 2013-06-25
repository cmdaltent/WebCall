class User < ActiveRecord::Base
  attr_accessible :email, :first_name, :last_name, :token, :username, :password, :password_confirmation
  has_secure_password
  
  # Meetings referenced here where scheduled by the User
  # The User is the organizer of the referenced meetings here
  has_many :meetings
  
  before_save { |user| user.email = email.downcase }
  before_save :create_token
  
  validates :first_name, :presence => true
  validates :last_name, :presence => true

  validates :password, :presence => true,
                      :length => {:in => 4..10}
  
  validates :username, :presence => true,
                       :length => {:minimum => 3},
                       :uniqueness => true
                       

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, 
                format: {with: VALID_EMAIL_REGEX },
                uniqueness: { case_sensitive: false },
                :length => {:minimum => 4}
              
              
private
  def create_token
    self.token = SecureRandom.uuid
  end


end
