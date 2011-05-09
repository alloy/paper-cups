class Ticket
  MACRUBY_TICKETS_LIST = 'macruby-tickets-bounces@lists.macosforge.org'
  
  def self.fetch_and_create_messages!
    # TODO this is so lame, but as we don't have more rooms atm, this will suffice
    room = Room.find_by_label('MacRuby')
    author = Member.find_by_full_name('Ticket')
    fetch do |ticket|
      room.messages.create!(:author => author, :body => ticket.message)
    end
  end
  
  def self.fetch
    Gmail.new(GMAIL_USERNAME, GMAIL_PASSWORD).emails_from(MACRUBY_TICKETS_LIST) do |email|
      yield new(email)
    end
  end
  
  def initialize(email)
    @email = email
  end
  
  def new?
    @email.subject[0,4] != 'Re: '
  end
  
  def closed?
    status == 'closed'
  end
  
  def status_changed?
    @email.body.include?('* status:')
  end
  
  def status
    @email.body.match(/Status:\s\s(\w+)/m)[1]
  end
  
  def resolution
    if m = @email.body.match(/Resolution:\s\s(\w+)/m)
      m[1]
    end
  end
  
  def message
    label = @email.body.split("\n").first
    if new?
      "New #{label}"
    elsif status == 'closed' && status_changed?
      "Closed as #{resolution} #{label}"
    elsif status == 'reopened'
      "Reopened #{label}"
    else
      "Commented #{label}"
    end
  end
end