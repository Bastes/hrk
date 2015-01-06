module Hrk
  class Heroku
    def initialize remote
      @remote = remote
    end

    def call command
      validate! command
      system %Q(heroku #{command} #{@remote})
    end

    private

    def validate! command
      raise ExplicitApplicationError.new, "You're calling a command on remote #{@remote} yet the command explicitly references #{command[%r{-[ar]\s+\S+}]}" if command =~ %r{ -[ra]\b}
    end

    class ExplicitApplicationError < Exception
    end
  end
end
