module Hrk
  module Execute
    class Command
      attr_reader :env

      ARG = /\A-[ar]\Z/

      def initialize
        @env = Hrk::Env.new
      end

      def call *args
        command, remote = command_and_remote args
        if remote
          raise ArgumentError.new "Invalid remote option" if remote.length != 2
          @env.remote = remote
          Hrk::Heroku.new(*remote).call(*command)
        else
          raise ArgumentError.new "No remote has been previously defined and the command does not explicitely mention a remote" unless @env.remote?
          Hrk::Heroku.new(*@env.remote).call(*command)
        end
      end

      private

      def command_and_remote args
        command, remote, *other_remotes = ([nil] + args).slice_before(ARG).to_a
        raise ArgumentError.new "Too many remotes or app" if other_remotes.any?
        [command.compact, remote]
      end
    end
  end
end
