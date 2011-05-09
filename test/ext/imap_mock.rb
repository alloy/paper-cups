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