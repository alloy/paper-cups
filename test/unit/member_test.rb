require File.expand_path('../../test_helper', __FILE__)

module GeneralValidationSpecs
  def self.included(spec)
    spec.class_eval do
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
  end
end

describe Member, "concerning a new record" do
  before do
    @member = Member.new(:email => 'new@example.com')
  end
  
  it "should not require a full name" do
    @member.full_name = ''
    @member.should.be.valid
  end
  
  it "should not require a password" do
    @member.password = ''
    @member.should.be.valid
  end
  
  it "should create an invitation token" do
    token = Token.generate
    Token.stubs(:generate).returns(token)
    
    @member.save!
    @member.invitation_token.should == token
  end
  
  it "should send an invitation" do
    @member.save!
    assert_emails(1) { @member.invite! }
  end
  
  it "should remove the invitation token before update" do
    @member.save!
    @member.update_attribute(:full_name, 'New Guy')
    @member.invitation_token.should.be nil
  end
  
  it "should return the invitation token as param if it exists" do
    @member.save!
    @member.to_param.should == @member.invitation_token
    @member.update_attribute(:full_name, 'New Guy')
    @member.to_param.should == @member.id.to_s
  end
  
  include GeneralValidationSpecs
end

describe Member, "concerning an existing record" do
  before do
    @member = members(:lrz)
  end
  
  it "should require a full name" do
    @member.full_name = ''
    @member.should.not.be.valid
    @member.errors.on(:full_name).should.not.be.blank
  end
  
  include GeneralValidationSpecs
end

describe 'A', Member do
  it "should not allow access to role" do
    members(:lrz).update_attributes(:role => 'admin')
    members(:lrz).reload.role.should == 'member'
  end
  
  it "should allow access to email" do
    members(:alloy).update_attributes(:email => 'new@example.com')
    members(:alloy).reload.email.should == 'new@example.com'
  end
  
  it "should be marked as being online in a room" do
    members(:alloy).online_in(rooms(:macruby))
    rooms(:macruby).members.online.should == [members(:alloy)]
  end
  
  it "should mark a member as being offline" do
    memberships(:lrz_in_macruby).online!
    members(:lrz).offline!
    rooms(:macruby).should.be.empty
  end
  
  it "should return whether or not the member is an admin" do
    members(:alloy).should.be.admin
    members(:lrz).should.not.be.admin
  end
end