module Hrk
  module Execute
    class Help
      def initialize fallback = nil
        @fallback = fallback
      end

      def call *args
        if args.empty? || args.first =~ %r(\A(?:(?:(?:-)?h)|(?:(?:--)?help))\Z)
          display || true
        else
          fallback *args
        end
      end

      def display
        puts <<-eos
Usage:
  hrk [remote]: command...
  hrk [h | help | -h | --help]

hrk remembers the last remote you've used to send a command on this terminal,
and use it by default when you omit the optional [remote] argument.

The command is whatever you would give heroku, except (obviously) for the
-r or -a argument.

Options:
  -h --help Display this screen.
        eos
      end

      def fallback *args
        if @fallback
          @fallback.call *args
        else
          raise ArgumentError.new
        end
      end
    end
  end
end
