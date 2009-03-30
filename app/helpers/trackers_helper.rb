module TrackersHelper

  def timeago(time, options = {})
    options[:class] ||= "timeago"
    content_tag(:abbr, time.to_s, options.merge(:title => time.getutc.iso8601)) if time
  end

  MINUTE = 60
  HOUR   = 60 * 60
  DAY    = 60 * 60 * 24


  def relative_time(time)
    return '' if time.nil?

    now = Time.now
    delta = now - time
    if (1..90) === delta 
      return "#{delta.round} seconds ago"
    end

    if ((1+90)..(MINUTE * 90)) === delta
      return "#{(delta / MINUTE).round} minutes ago" 
    end
    
    # Prefer 'yesterday' over '19 hours ago'
    yday = now - DAY
    if yday.day == time.day && 
       yday.month == time.month && 
       yday.year == time.year
      return "yesterday"
    end

    if ((1+MINUTE * 90)..(HOUR * 23)) === delta
      return "#{(delta / HOUR).round} hours ago" 
    end

    if ((1+DAY * 1)..(DAY * 6)) === delta
      return time.strftime('last %A') 
    end

    if time.year == now.year
      return time.strftime('%A, %d %B')
    end

    time.strftime('%A, %d %B %Y')
  end

  def bytes_to_human(bytes)

    # Shamelessly ported from
    # http://snippets.dzone.com/posts/show/3038
    float_size = bytes.to_f;
    return "%i bytes"  % float_size if float_size<1023
    
    float_size = float_size / 1024
    return "%1.1f KiB" % float_size if float_size<1023

    float_size = float_size / 1024
    return "%1.1f MiB" % float_size if float_size<1023
    
    float_size = float_size / 1024 
    return "%1.1f GiB" % float_size
  end


  def htidy(text)
    h(Piece.tidy_text(text))
  end
end
