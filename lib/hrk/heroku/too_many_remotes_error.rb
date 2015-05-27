module Hrk
  class Heroku
    class TooManyRemotesError < StandardError
      def initialize remote, other_remote
        "You're calling a command on remote #{remote.to_a.join " "} yet the command explicitly references #{other_remote.join " "}"
      end
    end
  end
end
