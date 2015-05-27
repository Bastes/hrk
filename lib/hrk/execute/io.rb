module Hrk
  module Execute
    module IO
      def self.puts string
        STDOUT.puts string
      end

      def self.gets
        STDIN.gets
      end

      def puts string
        IO.puts string
      end

      def gets
        IO.gets
      end
    end
  end
end
