module Hrk
  class Heroku
    def initialize remote_name
      @remote_name = remote_name
    end

    def call command
      validate! command
      system %Q(heroku #{command} -r #{@remote_name})
    end

    private

    def validate! command
      raise ExplicitApplicationError.new, "You're calling a command on remote #{@remote_name} yet the command explicitely references #{command[%r{-[ar]\s+\S+}]}" if command =~ %r{ -[ra]\b}
    end

    class ExplicitApplicationError < Exception
    end
  end
end
