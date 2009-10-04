require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'shift_subtitle_cli'

describe ShiftSubtitleCli do

  before(:each) do
    @cli = ShiftSubtitleCli.new
  end
  
  describe "running bin/shift_subtitle" do
    before :each do
      input = StringIO.new("1\n00:00:24,600 --> 00:00:27,800\nthis is a test...")
      @output = StringIO.new
      File.stub!(:new).and_return(input, @output)
    end

    it "should shift the time when an SRT file is provided" do   
      ARGV.clear.concat ['--operation', 'sub', '--time', '2,500', 'infile', 'outfile']
      eval File.read(File.join(File.dirname(__FILE__), '..', 'bin', 'shift_subtitle'))
      @output.string.should eql("1\n00:00:22,100 --> 00:00:25,300\nthis is a test...")
    end
  end

  it "should print help to stderr when no options are provided" do
    output = capture_stderr do
      lambda { @cli.parse_options([]) }.should raise_error(SystemExit)
    end
    output.should match(/Usage:/)
  end
  
  it "should set the input_file and output_file in the options hash" do
    options = @cli.parse_options(['--operation', 'add', '--time', '2,500', 'infile', 'outfile'])
    options[:input_file].should eql('infile')
    options[:output_file].should eql('outfile')
  end
  
  it "should not allow a missing argument" do
    args = ['--operation', 'add', '--time', '2,500', 'infile']
    output = capture_stderr do
      lambda { @cli.parse_options(args) }.should raise_error(SystemExit)
    end
  end
  
  it "should convert the operation, seconds, and milliseconds into a float of seconds to shift" do
    options = @cli.parse_options(['--operation', 'sub', '--time', '2,500', 'infile', 'outfile'])
    @cli.time_to_shift(options).should eql(-2.5)
  end
  
  it "should convert unusually large millisecond values correctly" do
    options = @cli.parse_options(['--operation', 'add', '--time', '2,5000', 'infile', 'outfile'])
    @cli.time_to_shift(options).should eql(7.0)
  end

  describe "when the --operation argument is specified" do
    it "should not allow an invalid operation" do
      args = ['--operation', 'foo', '--time', '2,500', 'infile', 'outfile']
      lambda { @cli.parse_options(args) }.should raise_error(OptionParser::InvalidArgument)
    end

    it "should allow the add operation and set the options hash" do
      options = @cli.parse_options(['--operation', 'add', '--time', '2,500', 'infile', 'outfile'])
      options[:operation].should eql(:add) 
    end
  end
  
  describe "when the --time argument is provided" do
    it "should not allow an invalid time" do
      args = ['--operation', 'add', '--time', 'XYZ', 'infile', 'outfile']
      output = capture_stderr do
        lambda { @cli.parse_options(args) }.should raise_error(OptionParser::InvalidArgument)
      end
    end

    it "should parse a valid time and set the options hash" do
      options = @cli.parse_options(['--operation', 'add', '--time', '2,500', 'infile', 'outfile'])
      options[:seconds].should eql(2)
      options[:milliseconds].should eql(500) 
    end
  end  
  
  def capture_stderr
    $stderr = StringIO.new
    yield
    $stderr.string
  ensure
    $stderr = STDERR
  end
end
