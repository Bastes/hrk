module Hrk
  module Execute
    class Remember
      include IO

      autoload :InvalidInputError, "hrk/execute/remember/invalid_input_error"

      def initialize next_callee
        @next_callee = next_callee
      end

      def call arguments
        @next_callee.call(remember_and_confirm!(arguments))
      end

      private

      def remember_and_confirm! arguments
        env = Hrk::Env.new
        return arguments if arguments.remote
        return arguments unless env.remote? && reuse_or_confirm!(arguments, env)
        arguments.on_remote env.remote
      end

      def reuse_or_confirm! arguments, env
        !(env.last_time? && env.last_time + 5 < Time.now) || confirm!(arguments, env)
      end

      def confirm! arguments, env
        puts "Please confirm that you want to run this command: `heroku #{(arguments.to_a + env.remote).join " "}` [Y]es [N]o:"
        get_valid_input! =~ /\Ay(?:es)?\Z/i
      end

      def get_valid_input!
        gets.strip.tap do |input|
          raise InvalidInputError.new(input) unless input =~ /\A(?:y(?:es)?)|(?:n(?:o)?)\Z/i
        end
      end
    end
  end
end
