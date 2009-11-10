require File.expand_path('../../../test_helper', __FILE__)

describe MessagesHelper do
  it "should return a formatted link" do
    link_to_messages_on_date(nil, :previous).should.be nil
    
    @room = rooms(:macruby)
    
    link = link_to(Date.today.to_formatted_s(:long_ordinal), room_messages_on_day_path(@room, :day => Date.today))
    link_to_messages_on_date(Date.today, :previous).should == '← ' + link
    link_to_messages_on_date(Date.today, :next).should == link + ' →'
  end
  
  it "should format a members' full name" do
    format_full_name(members(:alloy)).should == 'Eloy D.'
    format_full_name(members(:lrz)).should == 'Laurent S.'
  end
  
  it "should not format a message body that isn't only a url and escape" do
    body = " \thttp://example.com This is <em>not</em> only a url.\n "
    format_message(Message.new(:body => body)).should == h(body.strip)
  end
  
  it "should format a multiline message body as code and escape" do
    body = "  This\n  <em>is</em>\n  code"
    format_message(Message.new(:body => body)).should == "<pre>#{h(body)}</pre>"
  end
  
  it "should create an anchor if a message body only contains a url" do
    body = " \thttp://example.com/index.php?foo=bar%20baz\n"
    format_message(Message.new(:body => body)).should == link_to(body.strip, body.strip)
    
    body = " \thttps://example.com/index.php?foo=bar%20baz\n"
    format_message(Message.new(:body => body)).should == link_to(body.strip, body.strip)
  end
  
  it "should create an image tag if a message body only contains a url that seems to point to an image" do
    %w{ gif png jpg }.each do |ext|
      body = " \thttp://example.com/image.#{ext}\n"
      format_message(Message.new(:body => body)).should == image_tag(body.strip, :alt => '')
    end
  end
  
  it "should create an anchor to a youtube clip with an image tag that shows the poster frame" do
    body = "\t http://www.youtube.com/watch?foo=bar&v=ytf0M5fcqbs&baz=bla \n "
    poster_frame = image_tag('http://img.youtube.com/vi/ytf0M5fcqbs/0.jpg', :alt => '')
    format_message(Message.new(:body => body)).should == link_to(poster_frame, body.strip)
  end
end