class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :firstName
      t.string :lastName
      t.string :username
      t.string :password
      t.string :email

      t.timestamps
    end
  end
end
