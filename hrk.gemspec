Gem::Specification.new do |s|
  s.name          = 'hrk'
  s.version       = '0.0.6'
  s.summary       = 'Hrk remembers your heroku remotes'
  s.description   = <<-eos
Hrk gives you the hrk command that proxies commands to heroku, keeping track of
the latest remote you used so you don't have to keep on typing it on every
subsequent command.
                       eos
  s.authors       = ['Michel Belleville']
  s.email         = 'michel.belleville@gmail.com'
  s.homepage      = 'http://github.com/Bastes/hrk'
  s.license       = 'GPL-3'
  s.files         = Dir['README.md', 'bin/hrk', '{lib,spec}/**/*.rb']
  s.bindir        = 'bin'
  s.executables   = ['hrk']

  s.add_development_dependency 'rspec',              '= 3.1.0', '< 4.0.0'
  s.add_development_dependency 'nyan-cat-formatter', '= 0.11',  '< 1.0'
  s.add_development_dependency 'guard-rspec',        '= 4.5.0', '< 5.0.0'
end
