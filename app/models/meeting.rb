class Meeting < ActiveRecord::Base
  attr_accessible :description, :expectedDuration, :startDate, :title
  
  has_many :organizers, :dependent => true
  has_many :users, :through => :organizers
  
  
  validates :title, :presence => true,
                    :length => { :minimum => 1}
  validates :startDate, :presence => true
  validates :expectedDuration, :presence => true
  
end
