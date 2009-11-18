class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.integer :message_id
      t.string :filename
      t.string :content_type
      t.string :token
      t.timestamps
    end
  end
  
  def self.down
    drop_table :attachments
  end
end
