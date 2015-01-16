module Hrk
  module Execute
    autoload :Command,        'hrk/execute/command'
    autoload :Help,           'hrk/execute/help'
    autoload :ErrorTrap,      'hrk/execute/error_trap'
    autoload :HerokuDetector, 'hrk/execute/heroku_detector'

    def self.call *args
      executer.call(*args)
    end

    def self.executer
      ErrorTrap.new HerokuDetector.new Help.new Command.new
    end
  end
end
