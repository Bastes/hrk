module Hrk
  module Execute
    class ErrorTrap
      def initialize next_callee
        @next_callee = next_callee
      end

      def call *args
        if args.include? '--hrk-testing'
          @next_callee.call(*(args - ['--hrk-testing']))
        else
          begin
            @next_callee.call(*args)
          rescue
            puts "Error: #{$!.message}"
            false
          end
        end
      end
    end
  end
end
