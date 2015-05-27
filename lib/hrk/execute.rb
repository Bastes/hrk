module Hrk
  module Execute
    autoload :IO,             "hrk/execute/io"
    autoload :Command,        "hrk/execute/command"
    autoload :AskForRemote,   "hrk/execute/ask_for_remote"
    autoload :Remember,       "hrk/execute/remember"
    autoload :Help,           "hrk/execute/help"
    autoload :ErrorTrap,      "hrk/execute/error_trap"
    autoload :HerokuDetector, "hrk/execute/heroku_detector"
    autoload :RemoteDisplay,  "hrk/execute/remote_display"

    def self.call *args
      executer.call(Hrk::Heroku.new(args))
    end

    def self.executer
      ErrorTrap.new \
        HerokuDetector.new \
        RemoteDisplay.new \
        Help.new \
        Remember.new \
        AskForRemote.new \
        Command.new
    end
  end
end
