class Membership < ActiveRecord::Base
  belongs_to :room
  belongs_to :member
  
  def online!
    touch :last_seen_at
  end
  
  def offline!
    update_attribute :last_seen_at, nil
  end
end
