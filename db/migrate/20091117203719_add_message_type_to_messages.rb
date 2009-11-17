class AddMessageTypeToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :message_type, :string
  end

  def self.down
    remove_column :messages, :message_type
  end
end
