require 'pathname'
require 'fileutils'
require 'digest/md5'
require 'tmpdir'

module Hrk
  class Env
    attr_reader :tty_digest

    def initialize
      @tty_digest = Digest::MD5.hexdigest(`tty`)
    end

    def remote= args
      remote_path.write args.join(' ') unless remote == args
    end

    def remote
      remote_path.read.split(' ', 2) if remote?
    end

    def remote?
      remote_path.exist?
    end

    def tmp_path
      tmp_dir.join('hrk').
        tap { |path| FileUtils.mkdir_p(path) unless path.exist? }
    end

    def tmp_dir
      Pathname.new(ENV['XDG_RUNTIME_DIR'] || Dir.tmpdir)
    end

    def remote_path
      tmp_path.join tty_digest
    end
  end
end
