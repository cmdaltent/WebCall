class User < ActiveRecord::Base
  attr_accessible :email, :firstName, :lastName, :password, :username,:password_confirmation
  has_secure_password
  has_and_belongs_to_many :meetings
  
  before_save { |user| user.email = email.downcase }


    
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
                  


end
