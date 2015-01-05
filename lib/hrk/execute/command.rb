module Hrk
  module Execute
    class Command
      REMOTE_MATCHER = %r{\A(.+):\Z}

      attr_reader :env

      def initialize
        @env = Hrk::Env.new
      end

      def call remote, *args
        if remote == ':'
          raise ArgumentError.new('No remote has been previously defined') unless @env.remote?
          Hrk::Heroku.new(@env.remote).call(args.join(' '))
        else
          raise ArgumentError.new("#{remote.inspect} isn't a proper remote marker") unless remote =~ REMOTE_MATCHER
          remote_name = remote[REMOTE_MATCHER, 1]
          @env.remote = remote_name
          Hrk::Heroku.new(remote_name).call(args.join(' '))
        end
      end
    end
  end
end
