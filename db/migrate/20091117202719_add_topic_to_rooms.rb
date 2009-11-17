class AddTopicToRooms < ActiveRecord::Migration
  def self.up
    add_column :rooms, :topic, :string
  end

  def self.down
    remove_column :rooms, :topic
  end
end
