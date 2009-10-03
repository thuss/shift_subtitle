require 'optparse'
require 'shift_subtitle'

class ShiftSubtitleCli < ShiftSubtitle
  def execute(arguments)
    begin
      options = parse_options arguments
      input_file = File.new options[:input_file], 'r'
      output_file = File.new options[:output_file], 'w'
      shift_srt input_file, output_file, time_to_shift(options)
    ensure
      input_file.close unless input_file.nil?
      output_file.close unless output_file.nil?
    end
  end

  def parse_options(arguments)
    options = {}
    mandatory_options = [ :operation, :seconds, :milliseconds, :input_file, :output_file ]

    parser = OptionParser.new do |opts|
      opts.banner = <<-BANNER.gsub(/^      /,'')
      Shift Subtitle Ruby Challenge

      Usage: #{File.basename($0)} --operation [add|sub] --time [seconds,milliseconds] input_file output_file

      Options are:
      BANNER
      opts.separator ""

      opts.on("-o", "--operation add|sub", [:add, :sub], "Add or Subtract time") do |operation|
        options[:operation] = operation
      end

      opts.on("-t", "--time seconds,milliseconds", "Seconds AND milliseconds to add or subtract") do |time|
        if (time =~ /\d+,\d+/)
          options[:seconds], options[:milliseconds] = time.split(/,/).map!{ |t| t.to_i }
        else
          raise OptionParser::InvalidArgument, "should be seconds,milliseconds"
        end
      end

      opts.on("-h", "--help", "Show this help message.") { puts opts; exit 0 }

      opts.parse!(arguments)

      options[:input_file], options[:output_file] = arguments.pop(2) 

      if mandatory_options.find { |option| options[option].nil? } 
        $stderr.puts opts; exit 1
      end
    end
    options
  end

  # Converts the time options into a float such as :sub 2,500 => -2.5 
  def time_to_shift(options)
    shift_time = options[:seconds].to_i + options[:milliseconds].to_f/1000
    shift_time *= (options[:operation] == :sub)?-1:1
  end
end