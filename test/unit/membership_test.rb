require File.expand_path('../../test_helper', __FILE__)

describe 'A', Membership do
  it "should mark a member as being online" do
    memberships(:lrz_in_macruby).online!
    rooms(:macruby).members.online.should == [members(:lrz)]
  end
  
  it "should mark a member as being offline" do
    memberships(:lrz_in_macruby).online!
    memberships(:lrz_in_macruby).offline!
    rooms(:macruby).should.be.empty
  end
end