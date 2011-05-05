require File.expand_path('../../test_helper', __FILE__)

describe "On the", RoomsController, "a member" do
  before do
    login members(:lrz)
    @room = rooms(:macruby)
  end
  
  it "should for now redirect to the first room a member has access to" do
    new_room = Room.new; new_room.label = 'another room'; new_room.save!
    @authenticated.memberships.delete_all
    @authenticated.memberships.create(:room => new_room)
    
    get :index
    should.redirect_to room_url(new_room)
  end
  
  it "should see an overview of messages in the room, limited to the last 25" do
    sleep 1
    @room.messages.delete_all
    messages = Array.new(26) { @room.messages.create! :author => @authenticated, :body => "foo" }
    
    get :show, :id => @room.to_param
    assigns(:room).should == @room
    assigns(:messages).should.equal_list messages.last(25)
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
    data['online_members'].should.include members(:alloy).full_name
    data['online_members'].should.include members(:lrz).full_name
    @room.messages[1..-1].each do |message|
      data['messages'].should.include "data-message-id=\"#{message.id}\""
    end
    data['room_topic'].should == @room.topic
  end
  
  it "should be able to set the room topic" do
    put :update, :id => @room.to_param, :room => { :topic => 'Oeleboele!' }, :format => 'js'
    status.should.be :success
    response.body.should == 'Oeleboele!'
    
    @room.reload.topic.should == 'Oeleboele!'
    message = @room.messages.last
    message.author.should == members(:lrz)
    message.should.be.topic_changed_message
    message.body.should == "Laurent Sansonetti changed the room’s topic to ‘Oeleboele!’"
  end
  
  should.disallow.get :show, :id => rooms(:kitten)
  should.disallow.put :update, :id => rooms(:kitten)
end

describe "On the", RoomsController, "a member on an iOS device" do
  before do
    login members(:lrz)
    @room = rooms(:macruby)
  end

  %w{ html iphone ipad }.each do |format|
    it "should see an overview of messages in the room" do
      get :show, :id => @room.to_param, :format => format
      status.should.be :success
      template.should.be "rooms/show.#{format}.erb"
    end
  end
end

describe "On the", MembershipsController, "a visitor" do
  should.require_login.get :index
  should.require_login.get :show, :id => rooms(:kitten)
  should.require_login.put :update, :id => rooms(:kitten)
end
