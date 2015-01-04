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
  hrk remote: command..."
  hrk [h | help | -h | --help]"

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
