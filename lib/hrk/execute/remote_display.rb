module Hrk
  module Execute
    class RemoteDisplay
      def initialize fallback
        @env = Hrk::Env.new
        @fallback = fallback
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
          @fallback.call(*args)
        end
      end
    end
  end
end
