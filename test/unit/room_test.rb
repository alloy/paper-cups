require File.expand_path('../../test_helper', __FILE__)

describe Room, 'concerning validations' do
  it "should not be valid without a label" do
    room = Room.new
    room.should.not.be.valid
    room.label = 'MacRuby'
    room.should.be.valid
  end
end

describe 'A', Room do
  before do
    @room = rooms(:macruby)
  end
  
  it "should return the members with access to the room" do
    @room.members.should.equal_set members(:alloy, :lrz, :matt, :api)
  end
  
  it "should return the messages that were written in the room, ordered id" do
    @room.messages.should.equal_list @room.messages.sort_by(&:id)
  end
  
  it "should return the members that are currently in the room" do
    @room.should.be.empty
    
    @room.memberships.first.touch(:last_seen_at)
    @room.members.online.should == [@room.members.first]
    
    @room.memberships.each { |m| m.touch(:last_seen_at) }
    @room.members.online.should == @room.members
  end
  
  it "should return the message preceding the given one, excluding those that are topic changed messages" do
    m = @room.messages
    m[1].update_attribute(:message_type, 'topic')
    
    @room.message_preceding(m[0]).should.be nil
    @room.message_preceding(m[1]).should == m[0]
    @room.message_preceding(m[2]).should == m[0]
  end
  
  it "should return the most recent date that contains messages" do
    freeze_time!
    
    @room.messages[0].update_attribute(:created_at, 2.days.ago)
    @room.messages[1].update_attribute(:created_at, 1.day.ago)
    @room.messages[2].update_attribute(:created_at, Date.today)
    @room.messages[3].update_attribute(:created_at, 1.day.from_now)
    
    @room.previous_date_that_contains_messages(Date.today.to_s).should == 1.day.ago.to_date
    @room.previous_date_that_contains_messages(2.days.ago.to_date.to_s).should.be nil
  end
  
  it "should return the first coming date that contains messages" do
    freeze_time!
    
    @room.messages[0].update_attribute(:created_at, 1.day.ago)
    @room.messages[1].update_attribute(:created_at, Date.today)
    @room.messages[2].update_attribute(:created_at, 1.day.from_now)
    @room.messages[3].update_attribute(:created_at, 2.days.from_now)
    
    @room.next_date_that_contains_messages(Date.today.to_s).should == 1.day.from_now.to_date
    @room.next_date_that_contains_messages(2.days.from_now.to_date.to_s).should.be nil
  end
  
  it "should not allow access to label" do
    @room.update_attributes(:label => 'IronRuby')
    @room.reload.label.should == 'MacRuby'
  end
  
  it "should allow access to topic" do
    @room.update_attributes(:topic => 'Two kittens a day, keeps the stress away!')
    @room.reload.topic.should == 'Two kittens a day, keeps the stress away!'
  end
  
  it "should update the topic and insert a message to show that the topic was updated" do
    lambda {
      @room.set_topic(members(:lrz), 'Sacre blue!')
    }.should.differ('@room.messages.count', +1)
    @room.reload.topic.should == 'Sacre blue!'
    message = @room.messages.last
    message.author.should == members(:lrz)
    message.should.be.topic_changed_message
    message.body.should == "Laurent Sansonetti changed the room’s topic to ‘Sacre blue!’"
  end
  
  it "should return the last 5 attachments" do
    AttachmentSan::Variant.any_instance.stubs(:process!)
    AttachmentSan::Variant::Original.any_instance.stubs(:process!)
    
    attachment_messages = []
    12.times do |i|
      if i.odd?
        attachment_messages << (m = @room.messages.build :message_type => 'attachment', :author => members(:lrz))
        m.build_attachment
        m.save!
      else
        @room.messages.create! :body => 'a text message', :author => members(:lrz)
      end
    end
    
    @room.last_attachment_messages.should == attachment_messages.reverse.first(5)
  end
end