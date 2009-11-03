class AddLastSeenAtToMemberships < ActiveRecord::Migration
  def self.up
    add_column :memberships, :last_seen_at, :timestamp
  end

  def self.down
    remove_column :memberships, :last_seen_at
  end
end
