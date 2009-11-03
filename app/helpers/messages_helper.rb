module MessagesHelper
  YOUTUBE_POSTER_FRAME = 'http://img.youtube.com/vi/%s/0.jpg'
  
  def format_message(message)
    body = message.body.strip
    if body =~ /^https*:\/\/[^\s]+$/
      format_url body
    elsif body.include?("\n")
      content_tag :pre, h(message.body)
    else
      h body
    end
  end
  
  def format_url(body)
    if body =~ /^http:\/\/\w*\.*youtube.com\/watch.+?v=(\w+)/
      link_to(image_tag(YOUTUBE_POSTER_FRAME % $1, :alt => ''), body)
    elsif body.split('?').first =~ /\.(gif|png|jpg)$/
      image_tag body, :alt => ''
    else
      link_to body, body
    end
  end
end
