require File.expand_path('../../test_helper', __FILE__)

describe 'A', Room do
  it "should return the members with access to the room, ordered by email" do
    rooms(:macruby).members.should.equal_list members(:alloy, :lrz, :matt)
  end
  
  it "should return the messages that were written in the room, ordered by creation date" do
    messages(:daily_kitten).update_attribute(:created_at, Time.parse('1/1/1999'))
    rooms(:macruby).messages.should.equal_list messages(:daily_kitten, :patrick_hernandez)
  end
end