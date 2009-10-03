require File.dirname(__FILE__) + '/spec_helper.rb'

describe ShiftSubtitle do
  before(:each) do
    @shift_subtitle = ShiftSubtitle.new
  end

  describe "when shifting time" do
    it "should raise an exception on invalid input" do
      lambda { @shift_subtitle.shift_timestamp('X1:31:51,210', 0) }.should raise_error(ArgumentError)
    end

    it "should leave time unchanged when shifting by zero" do
      @shift_subtitle.shift_timestamp('01:31:51,210', 0).should eql('01:31:51,210')
    end

    it "should add time" do
      @shift_subtitle.shift_timestamp('01:31:51,210', 1.5).should eql('01:31:52,710')
    end

    it "should add time beyond the 24 hour boundary" do
      @shift_subtitle.shift_timestamp('23:59:59,500', 1.5).should eql('24:00:01,000')
    end

    it "should subtract time" do
      @shift_subtitle.shift_timestamp('01:31:51,210', -1.5).should eql('01:31:49,710')
    end

    it "should not subtract below zero" do
      @shift_subtitle.shift_timestamp('00:00:01,000', -1.5).should eql('00:00:00,000')
    end
  end

  describe "when processing srt input" do
    before(:each) do
      @input_srt = StringIO.new(<<-SRT.gsub(/^        /,'')
        1
        00:00:20,000 --> 00:00:24,400
        In connection with a dramatic increase
        in crime in certain neighbourhoods,

        2 
        00:00:24,600 --> 00:00:27,800 
        the government is implementing a new policy...
      SRT
      )
      @output_srt = StringIO.new
    end

    it "should output the shifted srt" do
      @shift_subtitle.shift_srt(@input_srt, @output_srt, 1.5)
      @output_srt.string.should eql(<<-SRTOUT.gsub(/^        /,'')
        1
        00:00:21,500 --> 00:00:25,900
        In connection with a dramatic increase
        in crime in certain neighbourhoods,

        2 
        00:00:26,100 --> 00:00:29,300 
        the government is implementing a new policy...
      SRTOUT
      )
    end
  end
  
end
