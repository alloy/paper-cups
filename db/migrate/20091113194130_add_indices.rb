class AddIndices < ActiveRecord::Migration
  def self.up
    add_index :memberships, :member_id
    add_index :memberships, :room_id
    
    add_index :messages, :room_id
    add_index :messages, :author_id
  end

  def self.down
    remove_index :messages, :author_id
    remove_index :messages, :room_id
    
    remove_index :memberships, :room_id
    remove_index :memberships, :member_id
  end
end
