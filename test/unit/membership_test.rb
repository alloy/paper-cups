require File.expand_path('../../test_helper', __FILE__)

describe 'A', Membership do
  it "should mark a member as being online" do
    rooms(:macruby).memberships.first.online!
    rooms(:macruby).members.online.should == [rooms(:macruby).members.first]
  end
end