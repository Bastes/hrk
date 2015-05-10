module Hrk
  module Execute
    class AskForRemote
      def initialize next_callee
        @next_callee = next_callee
      end

      def call *args
        @next_callee.call(*insure_remote(args))
      end

      private

      def insure_remote args
        return args unless remoteless? args
        puts "Please state the remote you want to run these commands on (ex: -r demo):"
        args + STDIN.gets.split(/\s+/)
      end

      def remoteless? args
        args.reverse.take(2).none? { |a| a =~ /\A-[ar]\Z/ }
      end
    end
  end
end
