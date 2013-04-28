class Meeting < ActiveRecord::Base
  attr_accessible :description, :expectedDuration, :isParticipating, :startDate, :title
end
