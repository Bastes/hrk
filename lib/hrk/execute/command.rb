module Hrk
  module Execute
    class Command
      attr_reader :env

      ARG = /\A-[ar]\Z/

      def initialize
        @env = Hrk::Env.new
      end

      def call *args
        remote, command = remote_and_command args
        if remote
          @env.remote = remote
          Hrk::Heroku.new(*remote).call(*command)
        else
          raise ArgumentError.new("No remote has been previously defined and the command does not explicitely mention a remote") unless @env.remote?
          Hrk::Heroku.new(*@env.remote).call(*command)
        end
      end

      def remote_and_command args
        args.slice_before { |arg| arg =~ ARG }.inject([nil, []]) do |r, slice|
          if slice.first =~ ARG
            raise ArgumentError.new('Remote option without value') if slice.length < 2
            raise ArgumentError.new('Too many remotes mentionned') if r.first
            [slice.take(2), r.last + slice.drop(2)]
          else
            [r.first, r.last + slice]
          end
        end
      end
    end
  end
end
