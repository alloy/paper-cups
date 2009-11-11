require File.expand_path('../../../test_helper', __FILE__)

describe MessagesHelper do
  it "should return a link which opens in a new window" do
    open_link_to('http://example.com', 'http://example.com').should ==
      link_to('http://example.com', 'http://example.com', :target => '_blank')
  end
  
  it "should return a pretty date link" do
    link_to_messages_on_date(nil, :previous).should.be nil
    
    @room = rooms(:macruby)
    
    link = open_link_to(Date.today.to_formatted_s(:long_ordinal), room_messages_on_day_path(@room, :day => Date.today))
    link_to_messages_on_date(Date.today, :previous).should == '← ' + link
    link_to_messages_on_date(Date.today, :next).should == link + ' →'
  end
  
  it "should format a members' full name" do
    format_full_name(members(:alloy)).should == 'Eloy D.'
    format_full_name(members(:lrz)).should == 'Laurent S.'
  end
  
  it "should format a multiline message body as code and escape" do
    body = "  This is\n  <em> http://example.com </em>\n  code"
    format_message(Message.new(:body => body)).should == "<pre>#{h(body)}</pre>"
  end
  
  it "should escape content for regular messages" do
    body = "  This is a <em>normal</em> message."
    format_message(Message.new(:body => body)).should == h(body.strip)
  end
  
  it "should create an anchor for each url in a message body that's not a multiline paste" do
    test = lambda do |url|
      [
        "Check this \t%s. link\n",
        "%s <= hilarious!",
        "%s. <= hilarious!",
        "Also hilarious: %s",
        "Also hilarious: %s."
      ].each do |body|
        format_message(Message.new(:body => body % url)).should == h(body.strip) % open_link_to(url, url)
      end
    end
    
    test.call("hTtP://some-examplE.com/inDex.php?foo=bar%20baz")
    test.call("hTtPs://some-examplE.com/inDex.php?foo=bar%20baz")
  end
  
  it "should create an image tag if a message body only contains a url that seems to point to an image" do
    %w{ gif pNg jpg JPEG }.each do |ext|
      body = " \thttp://example.com/image.#{ext}\n"
      format_message(Message.new(:body => body)).should == open_link_to(image_tag(body.strip, :alt => ''), body.strip)
    end
  end
  
  it "should create an anchor to a youtube clip with an image tag that shows the poster frame" do
    body = "\t http://www.yOutube.com/wAtch?foo=bar&v=ytF0M5fc-bs&baz=bla \n "
    poster_frame = image_tag('http://img.youtube.com/vi/ytF0M5fc-bs/0.jpg', :alt => '')
    format_message(Message.new(:body => body)).should == open_link_to(poster_frame, body.strip)
  end
end