require File.expand_path('../../test_helper', __FILE__)

describe "On the", MessagesController, " nested under a room, a member" do
  before do
    login members(:lrz)
    @room = rooms(:macruby)
  end
  
  it "should be able to create a message" do
    lambda {
      post :create, :room_id => @room.to_param, :message => { :body => "Sacre blue!" }
    }.should.differ('@room.messages.count', +1)
    
    assigns(:message).author.should == @authenticated
    assigns(:message).body.should == "Sacre blue!"
    should.redirect_to room_url(@room)
  end
  
  it "should create a message and see the newest messages" do
    memberships(:alloy_in_macruby).online!
    
    lambda {
      post :create, :room_id => @room.to_param, :since => @room.messages.first.to_param, :message => { :body => "Sacre blue!" }, :format => 'js'
      status.should.be :success
    }.should.differ('@room.messages.count', +1)
    
    data = JSON.parse(response.body)
    data['online_members'].should.include members(:alloy).full_name
    data['online_members'].should.include members(:lrz).full_name
    @room.reload.messages[1..-1].each do |message|
      data['messages'].should.include "data-message-id=\"#{message.id}\""
    end
  end
  
  it "should see all messages for the given date" do
    freeze_time!(Time.parse('01/01/2009'))
    messages = Message.all
    
    messages.last.update_attribute(:created_at, "2008-12-30")
    messages[1..2].each { |m| m.update_attribute(:created_at, "2008-12-31") }
    messages.first.update_attribute(:created_at, "2009-01-01")
    
    get :index, :room_id => @room.to_param, :day => '2008-12-31'
    
    status.should.be :success
    template.should.be 'messages/index'
    assigns(:messages).should.equal_list messages[1..2]
  end
  
  it "should see all messages matching the search query" do
    get :index, :room_id => @room.to_param, :q => 'itte'
    status.should.be :success
    template.should.be 'messages/index'
    assigns(:messages).should == [messages(:daily_kitten)]
  end
end