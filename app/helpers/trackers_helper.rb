module TrackersHelper

  def timeago(time, options = {})
    options[:class] ||= "timeago"
    content_tag(:abbr, time.to_s, options.merge(:title => time.getutc.iso8601)) if time
  end

  MINUTE = 60
  HOUR   = 60 * 60
  DAY    = 60 * 60 * 24

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
