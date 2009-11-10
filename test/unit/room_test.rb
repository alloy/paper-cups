require File.expand_path('../../test_helper', __FILE__)

describe Room, 'concerning validations' do
  it "should not be valid without a label" do
    room = Room.new
    room.should.not.be.valid
    room.label = 'MacRuby'
    room.should.be.valid
  end
end

describe 'A', Room do
  before do
    @room = rooms(:macruby)
  end
  
  it "should return the members with access to the room, ordered by email" do
    @room.members.should.equal_list members(:alloy, :lrz, :matt)
  end
  
  it "should return the messages that were written in the room, ordered id" do
    @room.messages.should.equal_list @room.messages.sort_by(&:id)
  end
  
  it "should return the members that are currently in the room" do
    @room.should.be.empty
    
    @room.memberships.first.touch(:last_seen_at)
    @room.members.online.should == [@room.members.first]
    
    @room.memberships.each { |m| m.touch(:last_seen_at) }
    @room.members.online.should == @room.members
  end
  
  it "should return the most recent date that contains messages" do
    freeze_time!
    
    @room.messages[0].update_attribute(:created_at, 2.days.ago)
    @room.messages[1].update_attribute(:created_at, 1.day.ago)
    @room.messages[2].update_attribute(:created_at, Date.today)
    @room.messages[3].update_attribute(:created_at, 1.day.from_now)
    
    @room.previous_date_that_contains_messages(Date.today.to_s).should == 1.day.ago.to_date
    @room.previous_date_that_contains_messages(2.days.ago.to_date.to_s).should.be nil
  end
  
  it "should return the first coming date that contains messages" do
    freeze_time!
    
    @room.messages[0].update_attribute(:created_at, 1.day.ago)
    @room.messages[1].update_attribute(:created_at, Date.today)
    @room.messages[2].update_attribute(:created_at, 1.day.from_now)
    @room.messages[3].update_attribute(:created_at, 2.days.from_now)
    
    @room.next_date_that_contains_messages(Date.today.to_s).should == 1.day.from_now.to_date
    @room.next_date_that_contains_messages(2.days.from_now.to_date.to_s).should.be nil
  end
end