module Hrk
  class Heroku
    class NoRemoteError < StandardError
      def initialize command
        super "No remote or app mentionned in the arguments: `#{command.to_a.join " "}`"
      end
    end
  end
end
