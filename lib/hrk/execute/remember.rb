module Hrk
  module Execute
    class Remember
      class InvalidInputError < StandardError
        def initialize input
          super "Can't understand `#{input}` ; aborting"
        end
      end

      def initialize next_callee
        @next_callee = next_callee
      end

      def call *args
        @next_callee.call(*remember_and_confirm!(args))
      end

      private

      def remember_and_confirm! args
        env = Hrk::Env.new
        return args unless remoteless?(args) && env.remote? && reuse_or_confirm!(args, env)
        args + env.remote
      end

      def reuse_or_confirm! args, env
        !(env.last_time? && env.last_time + 5 < Time.now) || confirm!(args, env)
      end

      def confirm! args, env
        puts "Please confirm that you want to run this command: `heroku #{(args + env.remote).join " "}` [Y]es [N]o:"
        get_valid_input! =~ /\Ay(?:es)?\Z/i
      end

      def get_valid_input!
        STDIN.gets.strip.tap do |input|
          raise InvalidInputError.new(input) unless input =~ /\A(?:y(?:es)?)|(?:n(?:o)?)\Z/i
        end
      end

      def remoteless? args
        args.reverse.take(2).none? { |a| a =~ /\A-[ar]\Z/ }
      end
    end
  end
end
