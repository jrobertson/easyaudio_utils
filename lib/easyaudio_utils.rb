#!/usr/bin/env ruby

# file: easyaudio_utils.rb

require 'wavtool'

# requirements:
# `apt-get install mplayer sox vorbis-tools

# installing youtube-dl:
# 
# `sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/bin/youtube-dl`
#
# `sudo chmod a+rx /usr/bin/youtube-dl`


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


class EasyAudioUtils
  extend CommandHelper


@commands = "
* capture # records audio in FLAC format
* concat_files # stiches wav files together
* convert # converts a file from 1 format to another #wav #ogg
* duration # return the duration for a wav or ogg 
* generate_silence # generates silence in a wav file
* play # plays using mplayer
* record # alias for capture_desktop
* split # split the wav file by silence
* youtube_dl # downloads audio in Ogg (opus) format
".strip.lines.map {|x| x[/(?<=\* ).*/]}.sort


  def initialize(audio_in=nil, audio_out='audio.wav', out: audio_out, 
                 working_dir: '/tmp')

    @file_in, @file_out, @working_dir = audio_in, out, working_dir

  end

  # records audio in mono audio
  # tested with .flac
  #
  def capture(show: false)

    command = "rec -c 1 -r 8000 -t alsa default #{@file_out} " + 
        "silence 1 0.1 5% 5 1.0 5%"
    run command, show

  end
  
  def concat_files(files=[])
    WavTool.new(out: @file_out, ).concat files
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
      OggInfo.open(@file_in).length.to_i
    when '.wav'
      WavTool.new().duration(@file_in)
    when '.mp3'
      Mp3Info.new(@file_in).length.to_i
    end    
    
  end
  
  # silence duration in seconds
  #
  def generate_silence(duration)
    WavTool.new(out: @out_file).silence duration: duration
  end
  
  alias record capture
  
  def play(show: false)
    command = "mplayer #{@file_out}"
    run command, show
  end
  
  # split by silence
  #
  def split(show: false)    
    command = "sox -V3 #{@file_in} #{@file_out} silence -l  0  " +
        " 1 0.5 0.1% : newfile : restart"
    run command, show
  end
  
  # Download and extract audio from a video on YouTube
  #
  # By default, Youtube-dl will save the audio in Ogg (opus) format.
  #
  def youtube_dl(show: false)    
    
    command = "youtube-dl -x #{url=@file_in}"
    command += ' -o ' + @file_out if @file_out
    run command, show    

  end  


  private
  
  
  def ogg_to_wav()
    `oggdec #{@file_in} #{@file_out}`
  end  

  def run(command, show=false)

    if show then 
      command
    else
      puts "Using ->" + command
      system command
    end

  end  

end
