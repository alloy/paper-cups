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
    @authenticated.update_attribute(:created_at, Date.yesterday)
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
  
  it "should create an attachment message" do
    lambda {
      lambda {
        post :create, :room_id => @room.to_param, :message => { :attachment_attributes => { :uploaded_file => rails_icon } }
      }.should.differ('@room.messages.count', +1)
    }.should.differ('Attachment.count', +1)
    
    File.read(@room.reload.messages.last.attachment.original.file_path).should == rails_icon.read
    should.redirect_to room_url(@room)
  end
  
  it "should see all messages for the given date" do
    @authenticated.update_attribute(:created_at, Date.parse('12/30/2008'))
    messages = setup_messages_on_a_date
    get :index, :room_id => @room.to_param, :day => '2008-12-31'
    status.should.be :success
    template.should.be 'messages/index'
    assigns(:messages).should.equal_list messages
  end
  
  it "should not see messages for the given date if the member didn't join then yet" do
    @authenticated.update_attribute(:created_at, Date.parse('01/01/2009'))
    messages = setup_messages_on_a_date
    get :index, :room_id => @room.to_param, :day => '2008-12-31'
    status.should.be :success
    template.should.be 'messages/index'
    assigns(:messages).should.be.empty
  end
  
  it "should see all messages matching the search query" do
    @authenticated.update_attribute(:created_at, Date.yesterday)
    get :index, :room_id => @room.to_param, :q => 'itte'
    status.should.be :success
    template.should.be 'messages/index'
    assigns(:messages).should == [messages(:daily_kitten)]
  end
  
  it "should not see messages matching the search query that were created before the member joined" do
    @authenticated.update_attribute(:created_at, Date.tomorrow)
    get :index, :room_id => @room.to_param, :q => 'itte'
    status.should.be :success
    template.should.be 'messages/index'
    assigns(:messages).should.be.empty
  end
  
  should.disallow.get :index, :room_id => rooms(:kitten)
  should.disallow.post :create, :room_id => rooms(:kitten), :message => { :body => "Sacre blue!" }
  
  private
  
  def setup_messages_on_a_date
    freeze_time!(Time.parse('01/01/2009'))
    messages = Message.all
    messages.last.update_attribute(:created_at, "2008-12-30")
    messages[1..2].each { |m| m.update_attribute(:created_at, "2008-12-31") }
    messages.first.update_attribute(:created_at, "2009-01-01")
    messages[1..2]
  end
end

describe "On the", MembershipsController, "a visitor" do
  should.require_login.get :index, :room_id => rooms(:kitten)
  should.require_login.post :create, :room_id => rooms(:kitten), :message => { :body => "Sacre blue!" }
end