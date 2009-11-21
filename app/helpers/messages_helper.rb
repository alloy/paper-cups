module MessagesHelper
  YOUTUBE_POSTER_FRAME = 'http://img.youtube.com/vi/%s/0.jpg'
  
  MULTILINE = /\n/m
  
  ANY_URL = /(https*:\/\/.+?)(\s|\.\s|\.$|$)/i
  ONLY_URL = /^https*:\/\/[^\s]+$/i
  IMAGE_URL = /\.(gif|png|jpe?g)\??/i
  YOUTUBE_URL = /^http:\/\/\w*\.*youtube.com\/watch.+?v=([\w-]+)/i
  
  def timestamp_message_needed?(message)
    @last_message.nil? || @last_message.created_at < (message.created_at - TIMESTAMP_MESSAGE_INTERVAL)
  end
  
  def authors_name_needed?(message)
    @last_message.nil? || @last_message.author != message.author
  end
  
  def open_link_to(content, url, options = {})
    link_to content, url, options.merge(:target => '_blank')
  end
  
  def link_to_messages_on_date(date, direction)
    if date
      path = room_messages_on_day_path(@room, :day => date)
      link = open_link_to(date.to_formatted_s(:long_ordinal), path)
      direction == :previous ? '← ' + link : link + ' →'
    end
  end
  
  def format_message(message)
    if message.attachment_message?
      format_attachment_message(message)
    else
      case body = (message.attachment_message? ? message.attachment.original.public_path : message.body.strip)
      when ONLY_URL
        format_special_link body
      when MULTILINE
        "<pre>#{h(message.body)}</pre>"
      end || h(body).gsub(ANY_URL) { "#{link_to($1, $1, :target => '_blank')}#{$2}" }
    end
  end
  
  def format_special_link(url)
    case url
    when YOUTUBE_URL
      open_link_to(image_tag(YOUTUBE_POSTER_FRAME % $1, :alt => ''), url)
    when IMAGE_URL
      open_image_link(url)
    end
  end
  
  def format_attachment_message(message)
    path = message.attachment.original.public_path
    path =~ IMAGE_URL ? open_image_link(path) : open_link_to(h(message.body), path)
  end
  
  def open_image_link(url)
    open_link_to(image_tag(url, :alt => ''), url)
  end
  
  def format_full_name(member)
    name = h(member.full_name)
    parts = name.split(' ')
    return name if parts.length == 1
    parts[0..-2].join(' ') + parts.last
    "#{parts[0..-2].join(' ')} #{parts.last[0,1]}."
  end
end
