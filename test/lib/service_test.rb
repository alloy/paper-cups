require File.expand_path('../../test_helper', __FILE__)

describe "Service" do
  it "should return the service for the given name" do
    Service.find('git_hub').should.be Service::GitHub
  end
  
  it "should return `nil' if no service for the given name is found" do
    Service.find('foo_bar').should.be nil
  end
end

describe "Service::GitHub" do
  it "should create new messages for each commit" do
    room = rooms(:macruby)
    lambda {
      Service::GitHub.new.create_message(room, members(:api), :payload => File.read(fixture('git_hub_payload.json')))
    }.should.differ('room.messages.count', +2)
    
    message1, message2 = room.reload.messages.last(2)
    
    message1.author.should == members(:api)
    message1.room.should == room
    message1.body.should == '[github - master] okay i give in (http://github.com/defunkt/github/commit/41a212ee83ca127e3c8cf465891ab7216a705f59) -- Chris Wanstrath'
    
    message2.author.should == members(:api)
    message2.room.should == room
    message2.body.should == '[github - master] update pricing a tad (http://github.com/defunkt/github/commit/de8251ff97ee194a289832576287d6f8ad74e3d0) -- Chris Wanstrath'
  end
end