module Hrk
  class Heroku
    def initialize *remote
      @remote = remote
    end

    def call *command
      validate! command
      puts "Executing `#{(["heroku"] + command + @remote).join " "}`..."
      exec "heroku", *(command + @remote)
    end

    private

    def validate! command
      remote = (command.each_cons(2).detect { |(parameter, _)| parameter =~ %r{\A-[ar]\Z} }.join " " rescue nil)
      raise ExplicitApplicationError.new, "You're calling a command on remote #{@remote.join " "} yet the command explicitly references #{remote}" if remote
    end

    def exec *command
      Signal.trap("INT") {}
      Process.wait fork { Kernel.exec(*command) }
      $?.success?.tap { Signal.trap("INT", "DEFAULT") }
    end

    class ExplicitApplicationError < Exception
    end
  end
end
