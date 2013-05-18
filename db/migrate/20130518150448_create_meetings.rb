class CreateMeetings < ActiveRecord::Migration
  def change
    create_table :meetings do |t|
      t.string :title
      t.long :startDate
      t.long :expectedDuration
      t.string :description
      t.boolean :private
      t.string :token
      t.reference :user

      t.timestamps
    end
    add_index :meetings, :user_id
  end
end
