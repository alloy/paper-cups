class AddFullNameToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :full_name, :string
  end

  def self.down
    remove_column :members, :full_name
  end
end
