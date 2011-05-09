require File.expand_path('../../test_helper', __FILE__)

describe "Ticket" do
  before do
    Net::IMAP.reset!
    @tickets = []
    Ticket.fetch { |ticket| @tickets << ticket }
  end
  
  it "yields a Ticket instance per email from the MacRuby trac site" do
    @tickets.size.should == 6
  end
  
  it "returns whether or not the entry is a new ticket" do
    @tickets[0].should.be.new
    @tickets[1].should.not.be.new # this is parsed from the subject, not the status field!
    @tickets[2].should.not.be.new
    @tickets[3].should.not.be.new
    @tickets[4].should.not.be.new
    @tickets[5].should.not.be.new
  end
  
  it "returns whether or not the entry is a closed ticket" do
    @tickets[0].should.not.be.closed
    @tickets[1].should.not.be.closed
    @tickets[2].should.be.closed
    @tickets[3].should.not.be.closed
    @tickets[4].should.be.closed
    @tickets[5].should.be.closed
  end
  
  it "returns whether or not the entry changed the status" do
    @tickets[0].should.not.status_changed
    @tickets[1].should.not.status_changed
    @tickets[2].should.status_changed
    @tickets[3].should.status_changed
    @tickets[4].should.status_changed
    @tickets[5].should.not.status_changed
  end
  
  it "returns the entry's status" do
    @tickets[0].status.should == 'new'
    @tickets[1].status.should == 'new'
    @tickets[2].status.should == 'closed'
    @tickets[3].status.should == 'reopened'
    @tickets[4].status.should == 'closed'
    @tickets[5].status.should == 'closed'
  end
  
  it "returns the resolution text" do
    @tickets[0].resolution.should == nil
    @tickets[1].resolution.should == nil
    @tickets[2].resolution.should == 'invalid'
    @tickets[3].resolution.should == nil
    @tickets[4].resolution.should == 'fixed'
    @tickets[5].resolution.should == 'fixed'
  end
end

describe "Ticket, concerning messages, " do
  before do
    Net::IMAP.reset!
  end
  
  it "creates a Message instance per email in the MacRuby room" do
    Message.delete_all
    lambda { Ticket.fetch_and_create_messages! }.should.differ('Message.count', +6)
    messages = rooms(:macruby).messages
    messages[0].body.should == "New #1270: A test ticket, please ignore."
    messages[1].body.should == "Commented #1270: A test ticket, please ignore."
    messages[2].body.should == "Closed as invalid #1270: A test ticket, please ignore."
    messages[3].body.should == "Reopened #1270: A test ticket, please ignore."
    messages[4].body.should == "Closed as fixed #1270: A test ticket, please ignore."
    messages[5].body.should == "Commented #1270: A test ticket, please ignore."
  end
end