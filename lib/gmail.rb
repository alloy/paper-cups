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
  
  def emails(conditions)
    query = %w{ NOT DELETED }
    conditions.each do |key, value|
      query << key.to_s.upcase
      query << value
    end
    @connection.uid_search(query).each do |uid|
      source = @connection.uid_fetch(uid, ['RFC822']).first.attr['RFC822']
      yield TMail::Mail.parse(source)
      @connection.uid_copy(uid, "[Gmail]/All Mail")
      @connection.uid_store(uid, "+FLAGS", [:Deleted])
    end
    @connection.expunge
    @connection.logout
    @connection.disconnect
  rescue Errno::ENOTCONN, Net::IMAP::NoResponseError, Net::IMAP::ByeResponseError => e
    Rails.logger.error "[!] Unable to connect to to Gmail: #{e.class.name}"
  end
end