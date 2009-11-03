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
  
  it "should return new messages since the given message id" do
    get :index, :room_id => @room.to_param, :since => @room.messages.first.to_param, :format => 'js'
    assigns(:messages).should.equal_list @room.messages[1..-1]
    @room.messages[1..-1].each do |message|
      assert_select "tr[data-message-id=#{message.id}]" do
        assert_select "th", :text => message.author.email
        assert_select "td", :text => message.body
      end
    end
  end
end