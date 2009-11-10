module MessagesHelper
  YOUTUBE_POSTER_FRAME = 'http://img.youtube.com/vi/%s/0.jpg'
  
  def link_to_with_long_date(date)
    link_to(date.to_formatted_s(:long_ordinal), room_messages_on_day_path(@room, :day => date)) if date
  end
  
  def format_message(message)
    body = message.body.strip
    if body =~ /^https*:\/\/[^\s]+$/
      format_url body
    elsif body.include?("\n")
      "<pre>#{h(message.body)}</pre>"
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
  
  def format_full_name(member)
    parts = h(member.full_name).split(' ')
    parts[0..-2].join(' ') + parts.last
    "#{parts[0..-2].join(' ')} #{parts.last[0,1]}."
  end
end
