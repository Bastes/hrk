module Hrk
  module Execute
    autoload :Command,   'hrk/execute/command'
    autoload :Help,      'hrk/execute/help'
    autoload :ErrorTrap, 'hrk/execute/error_trap'

    def self.call *args
      executer.call(*args)
    end

    def self.executer
      ErrorTrap.new Help.new Command.new
    end
  end
end
