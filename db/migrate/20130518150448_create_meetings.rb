class CreateMeetings < ActiveRecord::Migration
  def change
    create_table :meetings do |t|
      t.string :title
      t.integer :startDate
      t.integer :expectedDuration
      t.string :description
      t.boolean :private
      t.string :token
      t.references :user

      t.timestamps
    end
    add_index :meetings, :user_id
  end
end
