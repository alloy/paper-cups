require File.expand_path('../../test_helper', __FILE__)

describe Message, 'concerning validations' do
  before do
    @message = messages(:patrick_hernandez)
  end
  
  it "should be valid with an author, room, and body" do
    @message.should.be.valid
  end
  
  it "should be invalid without a body" do
    @message.body = ''
    @message.should.not.be.valid
    @message.errors.on(:body).should.not.be.blank
  end
  
  it "should be invalid without an associated room" do
    @message.room = nil
    @message.should.not.be.valid
    @message.errors.on(:room_id).should.not.be.blank
  end
  
  it "should be invalid without an associated member" do
    @message.author = nil
    @message.should.not.be.valid
    @message.errors.on(:author_id).should.not.be.blank
  end
end

describe "A", Message do
  before do
    @message = messages(:patrick_hernandez)
  end
  
  it "should return it's author" do
    @message.author.should == members(:matt)
  end
  
  it "should return the room it was written in" do
    @message.room.should == rooms(:macruby)
  end
end