class Room < ActiveRecord::Base
  has_many :memberships
  has_many :members, :through => :memberships, :order => :email
end
