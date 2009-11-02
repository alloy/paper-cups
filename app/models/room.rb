class Room < ActiveRecord::Base
  has_many :memberships
  has_many :members, :through => :memberships, :order => :email
  has_many :messages, :order => :created_at
end
