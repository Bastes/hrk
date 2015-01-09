module Hrk
  module Execute
    autoload :Command, 'hrk/execute/command'
    autoload :Help,    'hrk/execute/help'

    def self.call *args
      executer.call(*args)
    end

    def self.executer
      Help.new Command.new
    end
  end
end
