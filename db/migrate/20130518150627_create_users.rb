class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :e_mail
      t.string :username
      t.string :token

      t.timestamps
    end
  end
end
