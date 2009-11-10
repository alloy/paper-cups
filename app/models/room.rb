class Room < ActiveRecord::Base
  has_many :memberships
  has_many :members, :through => :memberships, :order => :email
  has_many :messages, :order => :id
  
  def empty?
    members.online.empty?
  end
  
  def previous_date_that_contains_messages(date)
    date_that_contains_messages(date, 'DESC', '<')
  end
  
  def next_date_that_contains_messages(date)
    date_that_contains_messages(Date.parse(date) + 1.day, 'ASC', '>=')
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
