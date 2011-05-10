require File.expand_path('../../test_helper', __FILE__)

describe "Gmail" do
  before do
    Net::IMAP.reset!
    @gmail = Gmail.new('bob', 'secret')
  end
  
  it "connects with the given username and password" do
    imap.connection_details.should == ['imap.gmail.com', 993, true, nil, false]
    imap.credentials.should == ['bob', 'secret']
  end
  
  it "selects the inbox" do
    imap.selected_mailbox.should == 'Inbox'
  end
  
  it "yields new emails from a specific address in reverse order" do
    yielded = []
    @gmail.emails(:from => 'test@example.org') do |email|
      yielded << email
    end
    yielded.map(&:subject).should == %w{ new1 new2 }
    yielded.map(&:body).should == %w{ new1 new2 }
  end
  
  it "yields nothing if there are no new emails" do
    yielded = []
    @gmail.emails(:from => 'no-new-mails@example.org') do |email|
      yielded << email
    end
    yielded.should.be.empty
  end
  
  it "deletes an email after it has been used" do
    @gmail.emails(:from => 'test@example.org') do |_|
      # shouldn't be deleted yet
      imap.copied_uids.should == nil
      imap.stored_uids.should == nil
    end
    imap.copied_uids.should == [[1, "[Gmail]/All Mail"], [2, "[Gmail]/All Mail"]]
    imap.stored_uids.should == [[1, "+FLAGS", [:Deleted]], [2, "+FLAGS", [:Deleted]]]
  end
  
  it "disconnects after yielding the emails" do
    @gmail.emails(:from => 'test@example.org') do |_|
      imap.should.be.connected
    end
    imap.should.not.be.connected
  end
  
  it "rescues Net::IMAP::NoResponseError" do
    lambda {
      @gmail.emails(:from => 'test@example.org') do |_|
        raise Net::IMAP::NoResponseError
      end
    }.should.not.raise
  end
  
  it "rescues Net::IMAP::ByeResponseError" do
    lambda {
      @gmail.emails(:from => 'test@example.org') do |_|
        raise Net::IMAP::ByeResponseError
      end
    }.should.not.raise
  end
  
  private
  
  def imap
    Net::IMAP.mock
  end
end