class Message < ActiveRecord::Base
  belongs_to :author, :class_name => 'Member'
  belongs_to :room
  
  named_scope :since, lambda { |id| { :conditions => ["messages.id > ?", id] } }
  
  def self.recent
    find(:all, :order => 'messages.id DESC', :limit => 25, :include => :author).reverse
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
  
  validates_presence_of :author_id, :room_id, :body
end
