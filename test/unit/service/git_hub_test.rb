require File.expand_path('../../../test_helper', __FILE__)

describe "Service::GitHub" do
  before do
    @room = rooms(:macruby)
    @member = members(:api)
    
    @expected_messages = [
      '[github/master] okay i give in (http://github.com/defunkt/github/commit/41a212ee83ca127e3c8cf465891ab7216a705f59) -- Chris Wanstrath',
      '[github/master] update pricing a tad (http://github.com/defunkt/github/commit/de8251ff97ee194a289832576287d6f8ad74e3d0) -- Chris Wanstrath',
      '[github/master] bananas are healthy! (http://github.com/defunkt/github/commit/123251ff97ee194a289832576287d6f8ad74e3d0) -- Chris Wanstrath'
    ]
  end
  
  it "should create new messages for each commit, for upto 3 commits" do
    lambda {
      Service::GitHub.new.create_message(@room, @member, :payload => File.read(fixture('git_hub_payload_3.json')))
    }.should.differ('@room.messages.count', +3)
    
    @room.reload.messages.last(3).each_with_index do |message, index|
      message.author.should == @member
      message.room.should == @room
      message.body.should == @expected_messages[index]
    end
  end
  
  it "should create new messages for only 2 commits, then one message for the rest, when over 3 commits" do
    lambda {
      Service::GitHub.new.create_message(@room, @member, :payload => File.read(fixture('git_hub_payload_5.json')))
    }.should.differ('@room.messages.count', +3)
    
    messages = @room.reload.messages.last(3)
    
    messages.first(2).each_with_index do |message, index|
      message.author.should == @member
      message.room.should == @room
      message.body.should == @expected_messages[index]
    end
    
    coalesced_message = messages.last
    coalesced_message.author.should == @member
    coalesced_message.body.should == '[github/master] Total of 5 commits: http://github.com/defunkt/github/compare/41a212e...789251f'
  end
end