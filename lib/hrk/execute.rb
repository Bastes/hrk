module Hrk
  module Execute
    autoload :Command, 'hrk/execute/command'
    autoload :Help,    'hrk/execute/help'

    def self.call *args
      executer.call *args
    end

    def self.executer
      Hrk::Execute::Help.new \
        Hrk::Execute::Command.new
    end
  end
end
