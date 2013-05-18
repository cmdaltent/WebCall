class User < ActiveRecord::Base
  attr_accessible :e_mail, :first_name, :last_name, :token, :username

  # Meetings referenced here where scheduled by the User
  # The User is the organizer of the referenced meetings here
  has_many :meetings, :dependent => destroy
  before_save { |user| user.email = email.downcase }
  before_save :create_token


    
  validates :firstName, :presence => true
  validates :lastName, :presence => true

  validates :password, :presence => true,
                      :length => {:in => 4..10}
  
  validates :password_confirmation, presence: true

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
