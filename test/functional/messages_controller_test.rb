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
end