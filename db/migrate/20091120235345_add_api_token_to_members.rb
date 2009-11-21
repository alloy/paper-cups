class AddApiTokenToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :api_token, :string
  end

  def self.down
    remove_column :members, :api_token
  end
end
