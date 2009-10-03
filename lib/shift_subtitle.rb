require 'time'

class ShiftSubtitle

  # Takes an SRT IO stream (such as File) and shifts it by shift_seconds (e.g. -2.5)
  def shift_srt(input_srt, output_srt, shift_seconds)
    input_srt.each_line do | line |
      srt_time_regex = /^(\d\d:\d\d:\d\d,\d\d\d)( --> )(\d\d:\d\d:\d\d,\d\d\d)/ 
      if (line =~ srt_time_regex)
        start_time = shift_timestamp($1, shift_seconds)
        end_time = shift_timestamp($3, shift_seconds)
        line.gsub!(srt_time_regex, start_time + $2 + end_time)        
      end
      output_srt.write line
    end
  end

  # Takes an SRT timestamp ('01:01:23,500') and shifts it by shift seconds (-2.5)
  def shift_timestamp(srt_time_string, shift_seconds)
    if (srt_time_string =~ /(\d\d):(\d\d):(\d\d),(\d\d\d)/)
      time = Time.parse('2000-01-01 ' + srt_time_string + 'UTC') + shift_seconds
      hours = time.hour
      case
        when time.day == 31 then hours = 0; time = Time.at(0).utc # Never go below 00:00:00,000
        when time.day > 1 then hours += (time.day - 1) * 24 # Support times > 23 hours
      end
      "#{'%02d'%hours}:#{'%02d'%time.min}:#{'%02d'%time.sec},#{'%03d'%(time.usec/1000)}"
    else
      raise ArgumentError, "unexpected SRT timestamp format " + srt_time_string
    end
  end

end