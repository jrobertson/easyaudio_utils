#!/usr/bin/env ruby

# file: easyaudio_utils.rb

require 'c32'
require 'wavefile'

# requirements:
# `apt-get install mplayer sox vorbis-tools


module CommandHelper
  using ColouredText
  
  def list(a=@commands)

    format_command = ->(s) do
      command, desc = s.split(/\s+#\s+/,2)
      " %s %s %s" % ['*'.blue, command, desc.to_s.light_black]
    end

    s = a.map {|x| format_command.call(x) }.join("\n")
    puts s
  end

  def search(s)
    list @commands.grep Regexp.new(s)
  end

end

module WavTool
  include WaveFile
    
  def wav_silence(filename, duration: 1)

    square_cycle = [0] * 100 * duration
    buffer = Buffer.new(square_cycle, Format.new(:mono, :float, 44100))

    Writer.new(filename, Format.new(:mono, :pcm_16, 22050)) do |writer|
      220.times { writer.write(buffer) }
    end

  end
  
  def wav_concat(files, save_file='audio.wav')
    
    Writer.new(save_file, Format.new(:stereo, :pcm_16, 22050)) do |writer|

      files.each do |file_name|

        Reader.new(file_name).each_buffer(samples_per_buffer=4096) do |buffer|
          writer.write(buffer)
        end

      end
    end
    
  end

  def duration(file_name)
    Reader.new(file_name).total_duration    
  end

end


class EasyAudioUtils
  extend CommandHelper
  include WavTool

@commands = "
* capture_desktop # records the desktop
* concat_files # stiches wav files together
* convert # converts a file from 1 format to another #wav #ogg
* duration # return the duration for a wav or ogg 
* generate_silence # generates silence in a wav file
* play # plays using mplayer
* record # alias for capture_desktop
".strip.lines.map {|x| x[/(?<=\* ).*/]}.sort


  def initialize(audio_in=nil, audio_out='audio.wav', out: audio_out, 
                 working_dir: '/tmp')

    @file_in, @file_out, @working_dir = audio_in, out, working_dir

  end

  # records audio in mono audio
  # tested with .flac
  #
  def capture()

    command = "rec -c 1 -r 8000 -t alsa default #{@file_out} " + 
        "silence 1 0.1 5% 5 1.0 5%"
    run command, show

  end
  
  def concat_files(files=[])
    wav_concat files, @file_out
  end
  
  alias concat concat_files
  
  def convert()
        
    if File.extname(@file_in) == '.ogg' then
        ogg_to_wav() if File.extname(@file_out) == '.wav' 
    end
    
  end
  
  def duration()
    
    case File.extname(@file_in)
    when '.ogg'
      ogg_duration()
    when '.wav'
      wav_duration()
    end    
    
  end
  
  # silence duration in seconds
  #
  def generate_silence(duration)
    wav_silence @out_file, duration: duration
  end
  
  alias record capture
  
  def play(show: false)
    command = "mplayer #{@file_out}"
    run command, show
  end


  private
  
  def ogg_duration()
    OggInfo.open(@file_in) {|ogg| ogg.length.to_i }    
  end
  
  def ogg_to_wav()
    `oggdec #{@file_in} #{@file_out}`
  end
  

  def run(command, show: false)

    if show then 
      command
    else
      puts "Using ->" + command
      system command
    end

  end  

end

