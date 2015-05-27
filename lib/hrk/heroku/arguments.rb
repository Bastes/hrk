module Hrk
  class Heroku
    class Arguments
      def initialize arguments
        @arguments = arguments
      end

      def == other
        other == @arguments
      end

      def to_ary
        @arguments
      end
      alias :to_a :to_ary

      def empty?
        @arguments.empty?
      end
    end
  end
end
