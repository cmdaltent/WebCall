class MeetingsUsersJoinTable < ActiveRecord::Migration
  def up
    create_table :meetings_users, :id => false do |t|
      t.integer :meeting_id
      t.integer :user_id
    end
  end
  
  def change
    create_table :meetings_users, :id => false do |t|
      t.integer :meeting_id
      t.integer :user_id
    end
  end

  def down
    drop_table :meetings_users
  end
end
