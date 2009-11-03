require File.expand_path('../../test_helper', __FILE__)

describe "On the", RoomsController, "a member" do
  before do
    login members(:lrz)
  end
  
  it "should see an overview of messages in the room" do
    get :show, :id => rooms(:macruby).to_param
    assigns(:room).should == rooms(:macruby)
    status.should.be :success
    template.should.be 'rooms/show'
  end
  
  it "should be marked as being online" do
    get :show, :id => rooms(:macruby).to_param
    rooms(:macruby).members.online.should == [@authenticated]
  end
end