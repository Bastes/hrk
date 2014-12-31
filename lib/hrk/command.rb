module Hrk
  class Command
    def call *args
      Hrk::Heroku.new(args.first).call(*(args.drop(1).join(' ')))
    end
  end
end
