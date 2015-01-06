module Hrk
  module Execute
    class Command
      attr_reader :env

      def initialize
        @env = Hrk::Env.new
      end

      def call *args
        raise ArgumentError.new("Too many remotes mentionned") if args.count('-r') > 1
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
        args.slice_before('-r').inject([nil, []]) do |r, slice|
          if r.first.nil? && slice.first == '-r' && slice.length > 1
            [slice.take(2), r.last + slice.drop(2)]
          else
            [r.first, r.last + slice]
          end
        end
      end
    end
  end
end
