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
end