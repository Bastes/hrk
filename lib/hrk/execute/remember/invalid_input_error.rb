module Hrk
  module Execute
    class Remember
      class InvalidInputError < StandardError
        def initialize input
          super "Can't understand `#{input}` ; aborting"
        end
      end
    end
  end
end
