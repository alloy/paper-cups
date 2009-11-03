class Member < ActiveRecord::Base
  embrace :authentication
  
  has_many :memberships
  
  named_scope :online, :conditions => ["memberships.last_seen_at >= ?", 5.minutes.ago]
  
  attr_accessible :full_name, :email
  
  def online_in(room)
    memberships.find_by_room_id(room.id).online!
  end
  
  def offline!
    memberships.select(&:last_seen_at).each(&:offline!)
  end
  
  private
  
  validates_presence_of :full_name
  validates_uniqueness_of :email
  validates_email :email
end