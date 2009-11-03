require File.expand_path('../../test_helper', __FILE__)

describe "On the", RoomsController, "a member" do
  before do
    login members(:lrz)
    @room = rooms(:macruby)
  end
  
  it "should see an overview of messages in the room" do
    get :show, :id => @room.to_param
    assigns(:room).should == @room
    status.should.be :success
    template.should.be 'rooms/show'
  end
  
  it "should be marked as being online" do
    get :show, :id => @room.to_param
    @room.members.online.should == [@authenticated]
  end
  
  it "should return new messages since the given message id" do
    memberships(:alloy_in_macruby).online!
    get :show, :id => @room.to_param, :since => @room.messages.first.to_param, :format => 'json'
    status.should.be :success
    
    data = JSON.parse(response.body)
    data['online_members'].should.include members(:alloy).email
    data['online_members'].should.include members(:lrz).email
    @room.messages[1..-1].each do |message|
      data['messages'].should.include "data-message-id=\"#{message.id}\""
    end
  end
end