module Hrk
  module Execute
    class Command
      attr_reader :env

      def initialize
        @env = Hrk::Env.new
      end

      def call arguments
        arguments.call.tap do
          @env.remote = arguments.remote
          @env.last_time = Time.now
        end
      end
    end
  end
end
