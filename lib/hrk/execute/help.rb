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
          fallback(*args)
        end
      end

      def display
        puts <<-eos
Usage:
  hrk
  hrk command [(-r remote | -a appname)] [options]...
  hrk [h | help | -h | --help]

The hrk command remembers the last app you've send a command to on a terminal
to use it when you omit the optional -r or -a option on subsequent calls.

The command is whatever you would give heroku, except (obviously) for the
-r or -a argument.

Note that whatever argument and/or options the command is composed of should not
be tampered with and passed as is to the heroku toolbelt command.

You can pass no option to hrk to have it return current memorized remote (the
command will fail when no remote have been defined).

Options:
  -h --help     Display this screen.
  -r remote     Sets the remote for this command and the following.
  -a appname    Sets the heroku app name for this command and the following.

  --hrk-testing Full exceptions stack trace delivered (testing purposes only).

More on the hrk command on the gem's website:
https://github.com/Bastes/hrk
        eos
      end

      def fallback *args
        if @fallback
          @fallback.call(*args)
        else
          raise ArgumentError.new
        end
      end
    end
  end
end
