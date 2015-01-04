Gem::Specification.new do |s|
  s.name          = 'hrk'
  s.version       = '0.0.5'
  s.summary       = 'Hrk 2 swim like a dolphin in a sea of heroku commands'
  s.description   = 'Hrk 2 swim like a dolphin in a sea of heroku commands'
  s.authors       = ['Michel Belleville']
  s.email         = 'michel.belleville@gmail.com'
  s.homepage      = 'http://github.com/Bastes/hrk'
  s.license       = 'GPL-3'
  s.files         = Dir['README.md', 'bin/hrk', '{lib,spec}/**/*.rb']
  s.bindir        = 'bin'
  s.executables   = ['hrk']

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'nyan-cat-formatter'
  s.add_development_dependency 'guard-rspec'
end
