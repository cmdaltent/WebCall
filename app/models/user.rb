class User < ActiveRecord::Base
  attr_accessible :email, :firstName, :lastName, :password, :username
  
  has_many :organizers, :dependent => true
  has_many :meetings, :through => :organizers

  validates :email, :presence => true,
  :length => {:minimum => 4},
  :uniqueness => true

  validates :firstName, :presence => true
  validates :lastName, :presence => true

  validates :password, :presence => true,
  :length => {:in => 4..10}

  validates :username, :presence => true,
  :length => {:minimum => 3},
  :uniqueness => true

end
