module Hrk
  module Execute
    class Command
      attr_reader :env

      def initialize
        @env = Hrk::Env.new
      end

      def call *args
        remote = remote_name args
        if remote
          @env.remote = remote
          Hrk::Heroku.new(remote).call(remoteless_command(remote, args))
        else
          raise ArgumentError.new("No remote has been previously defined and the command does not explicitely mention a remote") unless @env.remote?
          Hrk::Heroku.new(@env.remote).call(args.join(' '))
        end
      end

      private

      def remote_name args
        args.each_cons(2).detect { |(parameter, _)| parameter == '-r' }.join ' ' rescue nil
      end

      def remoteless_command remote, args
        args.join(' ').gsub(%r{\s*#{remote}\s*}, ' ').strip
      end
    end
  end
end
