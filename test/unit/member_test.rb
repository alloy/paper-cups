require File.expand_path('../../test_helper', __FILE__)

describe Member, "concerning validations" do
  before do
    @member = Member.new
  end
  
  it "should require a full name" do
    @member.full_name = ''
    @member.should.not.be.valid
    @member.errors.on(:full_name).should.not.be.blank
  end
  
  it "should require an email" do
    @member.email = ''
    @member.should.not.be.valid
    @member.errors.on(:email).should.not.be.blank
  end
  
  it "should require a valid email" do
    @member.email = 'invalid'
    @member.should.not.be.valid
    @member.errors.on(:email).should.not.be.blank
  end
  
  it "should require a unique email" do
    @member.email = members(:alloy).email
    @member.should.not.be.valid
    @member.errors.on(:email).should.not.be.blank
  end
end

describe 'A', Member do
  it "should allow access to email" do
    members(:alloy).update_attributes(:email => 'new@example.com')
    members(:alloy).reload.email.should == 'new@example.com'
  end
  
  it "should be marked as being online in a room" do
    members(:alloy).online_in(rooms(:macruby))
    rooms(:macruby).members.online.should == [members(:alloy)]
  end
end