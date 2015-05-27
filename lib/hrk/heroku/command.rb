module Hrk
  class Heroku
    class Command < Arguments
      def include? option
        @arguments.include? option
      end
    end
  end
end
