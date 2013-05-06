class Meeting < ActiveRecord::Base
  attr_accessible :description, :expectedDuration, :startDate, :title
  
  has_and_belongs_to_many :users
  
  validates :title, :presence => true,
                    :length => { :minimum => 1}
  validates :startDate, :presence => true
  validates :expectedDuration, :presence => true
  
end
