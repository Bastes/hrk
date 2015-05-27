module Hrk
  module Execute
    class HerokuDetector
      def initialize next_callee
        @next_callee = next_callee
      end

      def call arguments
        if heroku_present?
          @next_callee.call(arguments)
        else
          puts <<-eos
Error: The heroku command is missing!

Hrk uses the heroku command from the heroku toolbelt to communicate with your
servers. You will find all you need to install the heroku toolbelt here:
https://toolbelt.heroku.com/
          eos
        end
      end

      def heroku_present?
        `which heroku`
        $?.success?
      end
    end
  end
end
