require File.expand_path('../../test_helper', __FILE__)

require 'net/imap'
module Net
  class IMAP
    class Mock
      attr_reader :connection_details, :credentials, :selected_mailbox
      attr_reader :copied_uids, :stored_uids
      
      def initialize(host, port = nil, usessl = nil, certs = nil, verify = nil)
        @connection_details = [host, port, usessl, certs, verify]
        @connected = true
      end
      
      def login(username, password)
        @credentials = [username, password]
        @logged_in = true
      end
      
      def logout
        @logged_in = false
      end
      
      def disconnect
        @connected = false
      end
      
      def connected?
        @logged_in && @connected
      end
      
      def select(mailbox)
        @selected_mailbox = mailbox
      end
      
      def uid_search(keys, charset = nil)
        if keys == "NOT DELETED"
          [1, 2]
        else
          []
        end
      end
      
      def uid_fetch(uid, attr)
        case [uid, attr]
        when [1, ['RFC822']] then [FetchData.new(uid, 'RFC822' => email_fixture('email1.txt'))]
        when [2, ['RFC822']] then [FetchData.new(uid, 'RFC822' => email_fixture('email2.txt'))]
        end
      end
      
      def uid_copy(uid, mailbox)
        @_copied_uids ||= []
        @_copied_uids << [uid, mailbox]
      end
      
      def uid_store(uid, attr, flags)
        @_stored_uids ||= []
        @_stored_uids << [uid, attr, flags]
      end
      
      def expunge
        @copied_uids, @stored_uids, = @_copied_uids, @_stored_uids
      end
      
      private
      
      def email_fixture(name)
        File.read(File.join(FIXTURE_ROOT, 'emails', name))
      end
    end
    
    def self.new(host, port = PORT, usessl = false, certs = nil, verify = false)
      @mock = Mock.new(host, port, usessl, certs, verify)
    end
    
    def self.mock
      @mock
    end
    
    def self.reset!
      @mock = nil
    end
  end
end

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
  
  it "yields new emails" do
    yielded = []
    @gmail.emails do |email|
      yielded << email
    end
    yielded.map(&:subject).should == %w{ new1 new2 }
    yielded.map(&:body).should == %w{ new1 new2 }
  end
  
  it "deletes an email after it has been used" do
    @gmail.emails do |_|
      # shouldn't be deleted yet
      imap.copied_uids.should == nil
      imap.stored_uids.should == nil
    end
    imap.copied_uids.should == [[1, "[Gmail]/All Mail"], [2, "[Gmail]/All Mail"]]
    imap.stored_uids.should == [[1, "+FLAGS", [:Deleted]], [2, "+FLAGS", [:Deleted]]]
  end
  
  it "disconnects after yielding the emails" do
    @gmail.emails do |_|
      imap.should.be.connected
    end
    imap.should.not.be.connected
  end
  
  it "rescues Net::IMAP::NoResponseError" do
    lambda {
      @gmail.emails do |_|
        raise Net::IMAP::NoResponseError
      end
    }.should.not.raise
  end
  
  it "rescues Net::IMAP::ByeResponseError" do
    lambda {
      @gmail.emails do |_|
        raise Net::IMAP::ByeResponseError
      end
    }.should.not.raise
  end
  
  private
  
  def imap
    Net::IMAP.mock
  end
end