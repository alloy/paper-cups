require File.expand_path('../../test_helper', __FILE__)

describe 'A', Room do
  it "should return the members with access to the room, ordered by email" do
    rooms(:macruby).members.should.equal_list members(:alloy, :lrz, :matt)
  end
end