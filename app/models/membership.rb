class Membership < ActiveRecord::Base
  belongs_to :room
  belongs_to :member
end
