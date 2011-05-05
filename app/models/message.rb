class Message < ActiveRecord::Base
  belongs_to :author, :class_name => 'Member'
  belongs_to :room
  
  extend AttachmentSan::Has
  has_attachment :attachment
  accepts_nested_attributes_for :attachment
  before_create :set_attachment_metadata, :if => :attachment
  
  named_scope :since_member_joined, lambda { |member| { :conditions => ["messages.created_at > ?", member.created_at] } }
  named_scope :since, lambda { |id| { :conditions => ["messages.id > ?", id] } if id }
  named_scope :search, lambda { |query| { :conditions => ["messages.body LIKE ?", "%#{query}%"] } }

  def topic_changed_message?
    message_type == 'topic'
  end
  
  def attachment_message?
    message_type == 'attachment'
  end
  
  def self.recent
    find(:all,
      :order => 'messages.id DESC',
      :limit => 25,
      :include => :author
    ).reverse
  end
  
  def self.find_created_on_date(year, month, day)
    date = Date.new(year.to_i, month.to_i, day.to_i)
    find(:all, :conditions => [
      "created_at >= :beginning_of_day AND created_at < :beginning_of_next_day",
      { 
        :beginning_of_day => date.beginning_of_day,
        :beginning_of_next_day => (date + 1.day).beginning_of_day
      }
    ])
  end
  
  private
  
  def set_attachment_metadata
    self.message_type = 'attachment'
    self.body = attachment.filename
  end
  
  validates_presence_of :author_id, :room_id
  validates_presence_of :body, :unless => :attachment
end
