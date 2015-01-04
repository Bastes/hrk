module Hrk
  module Execute
    class Command
      REMOTE_MATCHER = %r{\A(.+):\Z}

      def call remote, *args
        raise ArgumentError.new("#{remote.inspect} isn't a proper remote marker") unless remote =~ REMOTE_MATCHER
        Hrk::Heroku.new(remote[REMOTE_MATCHER, 1]).call(args.join(' '))
      end
    end
  end
end
