module Hrk
  module Execute
    class RemoteDisplay
      def initialize next_callee
        @env = Hrk::Env.new
        @next_callee = next_callee
      end

      def call *args
        if args.empty?
          if @env.remote?
            puts @env.remote.join ' '
            true
          else
            false
          end
        else
          @next_callee.call(*args)
        end
      end
    end
  end
end
