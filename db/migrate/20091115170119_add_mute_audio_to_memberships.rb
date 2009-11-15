class AddMuteAudioToMemberships < ActiveRecord::Migration
  def self.up
    add_column :memberships, :mute_audio, :boolean, :default => false
  end

  def self.down
    remove_column :memberships, :mute_audio
  end
end
