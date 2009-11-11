module MessagesHelper
  YOUTUBE_POSTER_FRAME = 'http://img.youtube.com/vi/%s/0.jpg'
  
  MULTILINE = /\n/m
  
  ANY_URL = /(https*:\/\/.+?)(\s|\.\s|\.$|$)/i
  ONLY_URL = /^https*:\/\/[^\s]+$/i
  IMAGE_URL = /\.(gif|png|jpe?g)\??/i
  YOUTUBE_URL = /^http:\/\/\w*\.*youtube.com\/watch.+?v=([\w-]+)/i
  
  def link_to_messages_on_date(date, direction)
    if date
      path = room_messages_on_day_path(@room, :day => date)
      link = link_to(date.to_formatted_s(:long_ordinal), path)
      direction == :previous ? '← ' + link : link + ' →'
    end
  end
  
  def format_message(message)
    case body = message.body.strip
    when ONLY_URL
      format_special_link body
    when MULTILINE
      "<pre>#{h(message.body)}</pre>"
    else
      body.gsub(ANY_URL) { "#{link_to($1, $1)}#{$2}" }
    end
  end
  
  def format_special_link(url)
    case url
    when YOUTUBE_URL
      link_to(image_tag(YOUTUBE_POSTER_FRAME % $1, :alt => ''), url)
    when IMAGE_URL
      image_tag url, :alt => ''
    end
  end
  
  def format_full_name(member)
    parts = h(member.full_name).split(' ')
    parts[0..-2].join(' ') + parts.last
    "#{parts[0..-2].join(' ')} #{parts.last[0,1]}."
  end
end
