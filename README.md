# Introducing the Easyaudio_utils gem

## Installation

`apt-get install mplayer sox vorbis-tools`

## Usage

    require 'easyaudio_utils'

    a = 5.times.map {|n| "voice#{n+1}.wav"}
    EasyAudioUtils.new(out: 'out2.wav').concat a

    EasyAudioUtils.search 'concat'
    #=> * concat_files stiches wav files together

    EasyAudioUtils.list

## Output

<pre>
 * capture_desktop records the desktop
 * concat_files stiches wav files together
 * convert converts a file from 1 format to another #wav #ogg
 * duration return the duration for a wav or ogg 
 * generate_silence generates silence in a wav file
 * play plays using mplayer
 * record alias for capture_desktop
</pre>

## Resources

* easyaudio_utils https://rubygems.org/gems/easyaudio_utils

audio gem easyaudioutils wav ogg
