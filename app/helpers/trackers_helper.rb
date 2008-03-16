module TrackersHelper

  MINUTE = 60
  HOUR   = 60 * 60
  DAY    = 60 * 60 * 24


  def relative_time(time)
   return '' if time.nil?

    delta = Time.now - time
    case delta
      when 1..90 			: "#{delta.round} seconds ago"
      when (1+90)..(MINUTE * 90) 	: "#{(delta / MINUTE).round} minutes ago"
      when (1+MINUTE * 90)..(HOUR * 26) : "#{(delta / HOUR).round} hours ago"
      when (1+HOUR * 26)..(DAY * 2) 	: "yesterday"
      when (1+DAY * 2)..(DAY * 6) 	: time.strftime('%A')

      else time.strftime('%A, %d %B')
    end
   
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
