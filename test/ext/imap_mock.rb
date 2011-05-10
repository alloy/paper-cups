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
        if keys.join(" ") =~ /^NOT DELETED (FROM|CC) (.+?)$/
          @query = File.join($1, $2)
          email_fixtures.map { |f| File.basename(f, '.txt').to_i }.sort.reverse
        else
          []
        end
      end
      
      def uid_fetch(uid, attr)
        fixture = email_fixtures.find { |f| File.basename(f, '.txt').to_i == uid }
        if attr == ['RFC822'] && fixture
          [FetchData.new(uid, 'RFC822' => File.read(fixture))]
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
      
      def email_fixtures
        Dir.glob(File.join(FIXTURE_ROOT, 'emails', @query, '*.txt'))
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