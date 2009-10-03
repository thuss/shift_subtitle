class ShiftSubtitle
  VERSION = '0.0.1'
  
  # input_srt and output_src should be an IO subclass such as File or StringIO
  # shift_seconds can be a positive or negative float or int
  def shift_srt(input_srt, output_srt, shift_seconds)
    input_srt.each_line do | line |
      srt_time_regex = /^(\d\d:\d\d:\d\d,\d\d\d)( --> )(\d\d:\d\d:\d\d,\d\d\d)/ 
      if (line =~ srt_time_regex)
        start_time = shift_srt_time($1, shift_seconds)
        end_time = shift_srt_time($3, shift_seconds)
        line.gsub!(srt_time_regex, start_time + $2 + end_time)        
      end
      output_srt.write line
    end
  end
  
  # srt_time_string should be of format '01:32:06,783'
  # shift_seconds can be positive or negative float or int
  def shift_srt_time(srt_time_string, shift_seconds)
    if (srt_time_string =~ /(\d\d):(\d\d):(\d\d),(\d\d\d)/)
      s_hour, s_min, s_sec, s_usec = $1.to_i, $2.to_i, $3.to_i, $4.to_i
      time = Time.at(s_hour * 3600 + s_min * 60 + s_sec, s_usec * 1000).utc
      time += shift_seconds
      
      if time.to_f < 0 
        time = Time.at(0).utc 
      end
      
      hour = "%02d" % (time.hour + (time.day - 1) * 24)
      min = "%02d" % time.min
      sec = "%02d" % time.sec
      msec = "%03d" % (time.usec/1000)
      
      "#{hour}:#{min}:#{sec},#{msec}"
    else
      raise ArgumentError, "error parsing SRT time " + srt_time_string
    end
  end
    
end