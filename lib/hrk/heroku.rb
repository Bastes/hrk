module Hrk
  class Heroku
    def initialize remote_name
      @remote_name = remote_name
    end

    def call command
      system %Q(heroku #{command} -r #{@remote_name})
    end
  end
end
