require 'net/imap'

# Based on code from: http://railstips.org/blog/archives/2008/10/27/using-gmail-with-imap-to-receive-email-in-rails
class Gmail
  HOST = 'imap.gmail.com'
  PORT = 993
  
  def initialize(username, password)
    connect(username, password)
  end
  
  def emails(conditions)
    find_ids(conditions).each do |id|
      yield fetch_email(id)
      archive_email(id)
    end
    disconnect
  rescue Errno::ENOTCONN, Net::IMAP::NoResponseError, Net::IMAP::ByeResponseError => e
    Rails.logger.error "[!] Unable to connect to to Gmail: #{e.class.name}"
  end
  
  private
  
  def find_ids(conditions)
    @connection.uid_search(query(conditions)).reverse
  end
  
  def fetch_email(id)
    source = @connection.uid_fetch(id, ['RFC822']).first.attr['RFC822']
    TMail::Mail.parse(source)
  end
  
  def archive_email(id)
    @connection.uid_copy(id, "[Gmail]/All Mail")
    @connection.uid_store(id, "+FLAGS", [:Deleted])
  end
  
  def connect(username, password)
    @connection = Net::IMAP.new(HOST, PORT, true)
    @connection.login(username, password)
    @connection.select('Inbox')
  end
  
  def disconnect
    @connection.expunge # flush deleted emails
    @connection.logout
    @connection.disconnect
  end
  
  def query(conditions)
    query = %w{ NOT DELETED }
    conditions.each do |key, value|
      query << key.to_s.upcase
      query << value
    end
    query
  end
end