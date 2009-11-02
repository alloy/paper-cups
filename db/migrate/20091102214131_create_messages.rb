class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :room_id
      t.integer :author_id
      t.text :body
      t.timestamps
    end
  end
  
  def self.down
    drop_table :messages
  end
end
