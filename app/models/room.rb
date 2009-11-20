class Room < ActiveRecord::Base
  has_many :memberships
  has_many :members, :through => :memberships, :order => :email
  has_many :messages, :order => :id
  
  attr_accessible :topic
  
  def empty?
    members.online.empty?
  end
  
  def set_topic(member, topic)
    update_attribute(:topic, topic)
    messages.create :author => member, :message_type => 'topic', :body => "#{member.full_name} changed the room’s topic to ‘#{topic}’"
  end
  
  def message_preceding(message)
    messages.find(:first, :order => "messages.id DESC", :conditions => ["messages.message_type IS NULL AND messages.id < ?", message.id])
  end
  
  def previous_date_that_contains_messages(date)
    date_that_contains_messages(date, 'DESC', '<')
  end
  
  def next_date_that_contains_messages(date)
    date_that_contains_messages(Date.parse(date) + 1.day, 'ASC', '>=')
  end
  
  def last_attachment_messages
    messages.all :include => :attachment, :order => 'messages.id DESC', :conditions => { :message_type => 'attachment' }, :limit => 5
  end
  
  def search(query)
    messages.find :all, :conditions => ["messages.body LIKE ?", "%#{query}%"]
  end
  
  private
  
  def date_that_contains_messages(date, order, operator)
    message = messages.find(:first,
      :order => "messages.id #{order}",
      :conditions => ["messages.created_at #{operator} ?", date]
    )
    message.created_at.to_date if message
  end
  
  validates_presence_of :label
end
