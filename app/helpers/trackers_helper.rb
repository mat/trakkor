module TrackersHelper

  MINUTE = 60
  HOUR   = 60 * 60
  DAY    = 60 * 60 * 24


  def relative_time(time)

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
end
