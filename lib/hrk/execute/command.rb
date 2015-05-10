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
        Hrk::Heroku.new(*remote).call(*command).tap do
          @env.remote = remote
          @env.last_time = Time.now
        end
      end

      private

      def command_and_remote args
        command, remote, *other_remotes = ([nil] + args).slice_before(ARG).to_a
        raise ArgumentError.new "Too many remotes or app" if other_remotes.any?
        raise ArgumentError.new "No remote is mentionned" unless remote
        raise ArgumentError.new "Incomplete remote option #{remote.first}" if remote.length != 2
        [command.compact, remote]
      end
    end
  end
end
