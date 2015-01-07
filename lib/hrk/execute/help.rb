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
  hrk command [-r remote]...
  hrk [h | help | -h | --help]

hrk remembers the last remote you've used to send a command on this terminal,
and use it by default when you omit the optional -r option.

The command is whatever you would give heroku, except (obviously) for the
-r or -a argument.

Note that whatever argument or options the command is composed of should not
be tampered with and passed as is to the heroku toolbelt command.

Options:
  -h --help  Display this screen.
  -r remote  Sets the remote for this command and the following

More on the hrk command on the gem's website:
https://github.com/Bastes/hrk
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
