class Ticket
  MACRUBY_TICKETS_LIST = 'macruby-tickets-bounces@lists.macosforge.org'
  
  def self.fetch
    Gmail.new(GMAIL_USERNAME, GMAIL_PASSWORD).emails_from(MACRUBY_TICKETS_LIST) do |email|
      yield new(email)
      #break
    end
  end
  
  def initialize(email)
    @email = email
  end
  
  def new?
    @email.subject[0,4] != 'Re: '
  end
end