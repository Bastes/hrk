require 'pathname'
require 'fileutils'
require 'digest/md5'
require 'tmpdir'

module Hrk
  class Env
    def remote= args
      socket_path.write args.join(' ') unless remote == args
    end

    def remote
      socket_path.read.split(' ', 2) if remote?
    end

    def remote?
      socket_path.exist?
    end

    def tmp_path
      tmp_dir.join('hrk').
        tap { |path| FileUtils.mkdir_p(path) unless path.exist? }
    end

    def tmp_dir
      Pathname.new(ENV['XDG_RUNTIME_DIR'] || Dir.tmpdir)
    end

    def socket_path
      tmp_path.join Digest::MD5.hexdigest(`tty`)
    end
  end
end
