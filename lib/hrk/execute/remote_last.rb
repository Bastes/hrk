module Hrk
  module Execute
    class RemoteLast
      ARG = /\A-[ar]\Z/

      def initialize next_callee
        @next_callee = next_callee
      end

      def call *args
        @next_callee.call(*order(args))
      end

      def order args
        args.slice_before { |arg| arg =~ ARG }.inject([[], nil]) do |r, slice|
          if slice.first =~ ARG
            raise ArgumentError.new("Too many remotes mentionned") if r.last
            [r.first + slice.drop(2), slice.take(2)]
          else
            [r.first + slice, r.last]
          end
        end.flatten.compact
      end
    end
  end
end
