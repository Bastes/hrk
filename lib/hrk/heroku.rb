module Hrk
  class Heroku
    class TooManyRemotesError < StandardError
    end

    class NoRemoteError < StandardError
    end

    class Arguments
      class Part
        def initialize arguments
          @arguments = arguments
        end

        def == other
          other == @arguments
        end

        def to_ary
          @arguments
        end
        alias :to_a :to_ary
      end

      class Remote < Part
      end

      class Command < Part
      end

      attr_reader :remote, :command

      def initialize arguments
        index = arguments.each_cons(2).to_a.index { |(arg, _)| arg =~ /\A-[ar]\Z/ }
        @remote  = index && Remote.new(arguments[index, 2])
        @command = Command.new((index && arguments[0, index] + arguments[index + 2, arguments.size]) || arguments)
      end

      def to_ary
        @command.to_a + (@remote.to_a || [])
      end
      alias :to_a :to_ary

      def == other
        other == to_ary
      end

      def call
        validate! command
        puts "Executing `#{to_execute.join " "}`..."
        exec to_execute
      end

      private

      def validate! command
        raise NoRemoteError.new "No remote or app mentionned in the arguments: `#{command.to_a.join " "}`" unless remote
        other_remote = (command.to_a.each_cons(2).detect { |(parameter, _)| parameter =~ %r{\A-[ar]\Z} } rescue nil)
        raise TooManyRemotesError.new, "You're calling a command on remote #{remote.to_a.join " "} yet the command explicitly references #{other_remote.join " "}" if other_remote
      end

      def to_execute
        ["heroku"] + to_a
      end

      def exec *command
        Signal.trap("INT") {}
        Process.wait fork { Kernel.exec(*command) }
        $?.success?.tap { Signal.trap("INT", "DEFAULT") }
      end
    end

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
      raise TooManyRemotesError.new, "You're calling a command on remote #{@remote.join " "} yet the command explicitly references #{remote}" if remote
    end

    def exec *command
      Signal.trap("INT") {}
      Process.wait fork { Kernel.exec(*command) }
      $?.success?.tap { Signal.trap("INT", "DEFAULT") }
    end
  end
end
