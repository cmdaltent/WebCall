class ReconfigureStartDateMeeting < ActiveRecord::Migration
  def up
    change_column :meetings, :startDate, :datetime
    Meeting.all.each do |meeting|
      meeting.update_attributes!(:startDate => Time.at(meeting.startDate))
    end
  end

  def down
    change_column :meetings, :startDate, :integer
    Meeting.all.each do |meeting|
      meeting.update_attributes!(:startDate => Time.to_i)
    end
  end
end
