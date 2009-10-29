class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members do |t|
      t.string :role
      t.string :email
      t.string :hashed_password
      t.string :reset_password_token
      t.timestamps
    end
  end
  
  def self.down
    drop_table :members
  end
end
