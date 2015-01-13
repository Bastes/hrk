require './lib/hrk/version'

Gem::Specification.new do |s|
  s.name          = 'hrk'
  s.version       = Hrk::VERSION
  s.summary       = 'Hrk remembers your heroku remotes for you.'
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

  s.add_development_dependency 'rspec',              '~> 3.1',  '>= 3.1.0'
  s.add_development_dependency 'nyan-cat-formatter', '~> 0.11', '>= 0.11'
  s.add_development_dependency 'guard-rspec',        '~> 4.5',  '>= 4.5.0'
  s.add_development_dependency 'rake',               '~> 10.1', '>= 10.1.0'
  s.add_development_dependency 'rubygems-tasks',     '~> 0.2',  '>= 0.2.4'
  s.add_development_dependency 'simplecov',          '~> 0.9',  '>= 0.9.1'
end
