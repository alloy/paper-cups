require 'net/imap'

# Based on code from: http://railstips.org/blog/archives/2008/10/27/using-gmail-with-imap-to-receive-email-in-rails
class Gmail
  HOST = 'imap.gmail.com'
  PORT = 993
  MAILBOX = 'Inbox'
  QUERY = 'NOT DELETED'
  
  def initialize(username, password)
    @connection = Net::IMAP.new(HOST, PORT, true)
    @connection.login(username, password)
    @connection.select(MAILBOX)
  end
  
  def emails
    @connection.uid_search(QUERY).each do |uid|
      source = @connection.uid_fetch(uid, ['RFC822']).first.attr['RFC822']
      yield TMail::Mail.parse(source)
    end
  end
end