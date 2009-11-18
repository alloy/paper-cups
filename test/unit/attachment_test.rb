require File.expand_path('../../test_helper', __FILE__)

describe 'An', Attachment do
  it "should generate a token" do
    token = Token.generate
    Token.stubs(:generate).returns(token)
    
    attachment = Attachment.create!(:uploaded_file => rails_icon)
    attachment.reload.token.should == token
  end
  
  xit "should not be valid without a file" do
    @attachment.uploaded_file = nil
    @attachment.should.be.valid
    @attachment.errors.on(:filename).should.not.be.blank
  end
end