module Hrk
  module Execute
    autoload :Command,        'hrk/execute/command'
    autoload :Remember,       'hrk/execute/remember'
    autoload :RemoteLast,     'hrk/execute/remote_last'
    autoload :Help,           'hrk/execute/help'
    autoload :ErrorTrap,      'hrk/execute/error_trap'
    autoload :HerokuDetector, 'hrk/execute/heroku_detector'
    autoload :RemoteDisplay,  'hrk/execute/remote_display'

    def self.call *args
      executer.call(*args)
    end

    def self.executer
      ErrorTrap.new HerokuDetector.new RemoteDisplay.new Help.new RemoteLast.new Remember.new Command.new
    end
  end
end
