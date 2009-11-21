class Member < ActiveRecord::Base
  embrace :authentication
  
  has_many :memberships
  
  named_scope :online, :conditions => ["memberships.last_seen_at >= ?", 5.minutes.ago]
  
  before_create :create_invitation_token, :unless => :api?
  before_update :remove_invitation_token, :unless => :api?
  
  before_create :create_api_token, :if => :api?
  
  attr_accessible :full_name, :email, :time_zone
  
  # %w{ admin api }.each do |role|
  #   define_method("#{role}?") { self.role == role }
  # end
  
  def admin?
    role == 'admin'
  end
  
  def api?
    role == 'api'
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
  
  def create_api_token
    write_attribute :api_token, Token.generate
  end
  
  validates_presence_of :full_name, :unless => proc { |r| r.new_record? && !r.api? }
  validates_presence_of :time_zone, :unless => proc { |r| r.new_record? || r.api? }
  validates_uniqueness_of :email, :unless => :api?
  validates_email :email, :unless => :api?
end