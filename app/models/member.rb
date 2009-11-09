class Member < ActiveRecord::Base
  embrace :authentication
  
  has_many :memberships
  
  named_scope :online, :conditions => ["memberships.last_seen_at >= ?", 5.minutes.ago]
  
  before_create :create_invitation_token
  before_update :remove_invitation_token
  
  attr_accessible :full_name, :email
  
  def admin?
    role == 'admin'
  end
  
  def to_param
    invitation_token || id.to_s
  end
  
  def online_in(room)
    memberships.find_by_room_id(room.id).online!
  end
  
  def offline!
    memberships.select(&:last_seen_at).each(&:offline!)
  end
  
  def invite!
    Mailer.deliver_member_invitation(self)
  end
  
  private
  
  def create_invitation_token
    write_attribute :invitation_token, Token.generate
  end
  
  def remove_invitation_token
    write_attribute :invitation_token, nil
  end
  
  validates_presence_of :full_name, :unless => :new_record?
  validates_uniqueness_of :email
  validates_email :email
end