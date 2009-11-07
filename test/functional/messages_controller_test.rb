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
  
  it "should return all messages for the given date" do
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
end