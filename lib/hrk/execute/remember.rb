module Hrk
  module Execute
    class Remember
      def initialize next_callee
        @next_callee = next_callee
      end

      def call *args
        env = Hrk::Env.new
        if remoteless?(args) && env.remote?
          @next_callee.call(*args, *env.remote)
        else
          @next_callee.call(*args)
        end
      end

      private

      def remoteless? args
        args.reverse.take(2).none? { |a| a =~ /\A-[ar]\Z/ }
      end
    end
  end
end
