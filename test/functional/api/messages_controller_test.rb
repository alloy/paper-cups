require File.expand_path('../../../test_helper', __FILE__)

describe "On the", Api::MessagesController, ", nested under a service and room, an api member" do
  before do
    @room = rooms(:macruby)
  end
  
  it "should be able to create a message" do
    lambda {
      post :create, :api_token => members(:api).to_param,
                    :service_id => 'git_hub',
                    :room_id => @room.to_param,
                    :payload => File.read(fixture('git_hub_payload_3.json'))
    }.should.differ('@room.messages.count', +3)
    status.should.be :created
  end
end