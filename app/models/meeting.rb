class Meeting < ActiveRecord::Base
  attr_accessible :description, :expectedDuration, :startDate, :title
  
  validates :title, :presence => true,
                    :length => { :minimum => 1}
  validates :startDate, :presence => true
  validates :expectedDuration, :presence => true,
                               :minimum => 15*60
  
end
