require File.expand_path('../../../test_helper', __FILE__)

describe "On the", Api::MessagesController, ", nested under a service and room, an api member" do
  before do
    @room = rooms(:macruby)
  end
  
  it "should be able to create a message" do
    lambda {
      post :create, :api_token => members(:api).to_param,
                    :service_id => 'github',
                    :room_id => @room.to_param,
                    :message => { :body => "A commit message." }
    }.should.differ('@room.messages.count', +1)
    
    message = @room.reload.messages.last
    message.author.should == members(:api)
    message.room.should == @room
    message.body.should == 'A commit message.'
    
    status.should.be :created
  end
end