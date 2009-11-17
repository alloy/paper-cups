class AddTimeZoneToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :time_zone, :string, :default => 'UTC'
  end

  def self.down
    remove_column :members, :time_zone
  end
end
