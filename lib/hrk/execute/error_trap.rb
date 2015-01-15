module Hrk
  module Execute
    class ErrorTrap
      def initialize callee
        @callee = callee
      end

      def call *args
        if args.include? '--hrk-testing'
          @callee.call *(args - ['--hrk-testing'])
        else
          begin
            @callee.call *args
          rescue
            puts "Error: #{$!.message}"
            false
          end
        end
      end
    end
  end
end
