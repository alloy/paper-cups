require File.expand_path('../../test_helper', __FILE__)

describe "On the", MembershipsController, "a member" do
  before do
    login members(:lrz)
    @membership = @authenticated.memberships.first
  end
  
  it "should be able to update his settings" do
    put :update, :id => @membership.to_param, :membership => { :mute_audio => '1' }
    status.should.be :no_content
    @membership.reload.mute_audio.should.be true
  end
  
  should.disallow.put :update, :id => memberships(:alloy_in_macruby)
end

describe "On the", MembershipsController, "a visitor" do
  should.require_login.put :update, :id => memberships(:lrz_in_macruby)
end