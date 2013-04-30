class CreateMeetings < ActiveRecord::Migration
  def change
    create_table :meetings do |t|
      t.integer :startDate
      t.integer :expectedDuration
      t.string :title
      t.string :description

      t.timestamps
    end
  end
end
