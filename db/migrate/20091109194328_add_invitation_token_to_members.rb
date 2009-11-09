class AddInvitationTokenToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :invitation_token, :string
  end

  def self.down
    remove_column :members, :invitation_token
  end
end
