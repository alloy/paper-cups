class Member < ActiveRecord::Base
  embrace :authentication
  
  has_many :memberships
  
  named_scope :online, :conditions => ["memberships.last_seen_at >= ?", 5.minutes.ago]
  
  attr_accessible :email
  
  def online_in(room)
    memberships.find_by_room_id(room.id).online!
  end
  
  private
  
  validates_uniqueness_of :email
  validates_email :email
end