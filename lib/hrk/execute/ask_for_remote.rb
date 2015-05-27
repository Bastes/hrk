module Hrk
  module Execute
    class AskForRemote
      include IO

      def initialize next_callee
        @next_callee = next_callee
      end

      def call arguments
        @next_callee.call(insure_remote(arguments))
      end

      private

      def insure_remote arguments
        return arguments if arguments.remote
        puts "Please state the remote you want to run these commands on (ex: -r demo):"
        arguments.on_remote gets.split(/\s+/)
      end
    end
  end
end
