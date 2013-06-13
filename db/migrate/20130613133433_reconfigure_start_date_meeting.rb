class ReconfigureStartDateMeeting < ActiveRecord::Migration
  def up
    change_column :meetings, :startDate, :datetime
  end

  def down
    change_column :meetings, :startDate, :integer
  end
end
