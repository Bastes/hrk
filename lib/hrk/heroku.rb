module Hrk
  class Heroku
    autoload :Arguments,           "hrk/heroku/arguments"
    autoload :Remote,              "hrk/heroku/remote"
    autoload :Command,             "hrk/heroku/command"
    autoload :TooManyRemotesError, "hrk/heroku/too_many_remotes_error"
    autoload :NoRemoteError,       "hrk/heroku/no_remote_error"

    attr_reader :remote, :command

    def initialize arguments
      index = arguments.index { |option| option =~ /\A-[ar]\Z/ }
      @remote  = index && Remote.new(arguments[index, 2])
      @command = Command.new((index && arguments[0, index] + arguments[[index + 2, arguments.size].min, arguments.size]) || arguments)
    end

    def include? option
      @command.include? option
    end

    def - argument
      self.class.new(to_a - argument)
    end

    def to_ary
      @command.to_a + (@remote.to_a || [])
    end
    alias :to_a :to_ary

    def == other
      other == to_ary
    end

    def eql? other
      self == other && self.class == other.class
    end

    def on_remote other_remote
      self.class.new command.to_a + other_remote
    end

    def call
      validate! command
      puts "Executing `#{to_execute.join " "}`..."
      exec(*to_execute)
    end

    def inspect
      %Q(#<#{self.class.name} @command="#{@command.to_a.join " "}", @remote="#{@remote.to_a.join " "}">)
    end

    def empty?
      !@remote && @command.empty?
    end

    private

    def validate! command
      raise NoRemoteError.new command unless remote
      other_remote = (command.to_a.each_cons(2).detect { |(parameter, _)| parameter =~ %r{\A-[ar]\Z} } rescue nil)
      raise TooManyRemotesError.new remote, other_remote if other_remote
    end

    def to_execute
      ["heroku"] + to_a
    end

    def exec *command
      Signal.trap("INT") {}
      Process.wait fork { Kernel.exec(*command) }
      $?.success?.tap { Signal.trap("INT", "DEFAULT") }
    end
  end
end
