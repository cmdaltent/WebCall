class CreateOrganizer < ActiveRecord::Migration
  def up
    create_table :organizers do |t|
      t.integer :meeting_id, :null => false
      t.integer :user_id, :null => false
      t.boolean :is_organizer, :default => false
    end
  end
  
  def change
    create_table :organizers do |t|
      t.integer :meeting_id, :null => false
      t.integer :user_id, :null => false
      t.boolean :is_organizer, :default => false
    end
  end

  def down
    drop_table :organizers
  end
end
