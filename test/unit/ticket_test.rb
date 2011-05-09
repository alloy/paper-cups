require File.expand_path('../../test_helper', __FILE__)

describe "Ticket" do
  before do
    Net::IMAP.reset!
    @tickets = []
    Ticket.fetch { |ticket| @tickets << ticket }
  end
  
  it "yields a Ticket instance per email from the MacRuby trac site" do
    @tickets.size.should == 3
  end
  
  it "returns whether or not an email is for a new ticket" do
    @tickets[0].should.be.new
    @tickets[1].should.not.be.new
    @tickets[2].should.not.be.new
  end
end