require 'net/imap'

# Based on code from: http://railstips.org/blog/archives/2008/10/27/using-gmail-with-imap-to-receive-email-in-rails
class Gmail
  HOST = 'imap.gmail.com'
  PORT = 993
  
  def initialize(username, password)
    @connection = Net::IMAP.new(HOST, PORT, true)
    @connection.login(username, password)
    @connection.select('Inbox')
  end
  
  def emails
    @connection.uid_search('NOT DELETED').each do |uid|
      source = @connection.uid_fetch(uid, ['RFC822']).first.attr['RFC822']
      yield TMail::Mail.parse(source)
      @connection.uid_copy(uid, "[Gmail]/All Mail")
      @connection.uid_store(uid, "+FLAGS", [:Deleted])
    end
    @connection.expunge
    @connection.logout
    @connection.disconnect
  rescue Net::IMAP::NoResponseError, Net::IMAP::ByeResponseError => e
    Rails.logger.error "[!] A #{e.class.name} error occurred when connecting to Gmail: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
  end
end