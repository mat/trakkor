module TrackersHelper

  MINUTE = 60
  HOUR   = 60 * 60
  DAY    = 60 * 60 * 24


  def relative_time(time)
   return '' if time.nil?

    delta = Time.now - time
    if (1..90) === delta 
      return "#{delta.round} seconds ago"
    end

    if ((1+90)..(MINUTE * 90)) === delta
      return "#{(delta / MINUTE).round} minutes ago" 
    end
    
    yesterday = Time.now - DAY
    if yesterday.wday == time.wday
      return "yesterday"
    end

    if ((1+MINUTE * 90)..(HOUR * 23)) === delta
      return "#{(delta / HOUR).round} hours ago" 
    end

    if ((1+DAY * 1)..(DAY * 6)) === delta
      return time.strftime('%A') 
    end

    time.strftime('%A, %d %B')
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
end
