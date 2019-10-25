Gem::Specification.new do |s|
  s.name = 'easyaudio_utils'
  s.version = '0.2.2'
  s.summary = 'A wrapper for various command-line audio utilities ' + 
      'under GNU/Linux.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/easyaudio_utils.rb']
  s.add_runtime_dependency('c32', '~> 0.2', '>=0.2.0')  
  s.add_runtime_dependency('wavtool', '~> 0.1', '>=0.1.0')
  s.add_runtime_dependency('ruby-mp3info', '~> 0.8', '>=0.8.10')
  s.signing_key = '../privatekeys/easyaudio_utils.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/easyaudio_utils'
end
