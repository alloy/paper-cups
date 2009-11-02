class Message < ActiveRecord::Base
  belongs_to :author, :class_name => 'Member'
  belongs_to :room
  
  private
  
  validates_presence_of :author_id, :room_id, :body
end
