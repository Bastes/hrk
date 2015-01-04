require 'pathname'
require 'fileutils'
require 'digest/md5'
require 'tmpdir'

module Hrk
  class Env
    def remote= remote_name
      if remote_name
        socket_path.write remote_name unless remote == remote_name
      else
        socket_path.delete if remote?
      end
    end

    def remote
      socket_path.read if remote?
    end

    def remote?
      socket_path.exist?
    end

    def tmp_path
      Pathname.
        new(File.join(ENV['XDG_RUNTIME_DIR'] || Dir.tmpdir, 'hrk')).
        tap { |path| FileUtils.mkdir_p(path) unless path.exist? }
    end

    def socket_path
      tmp_path.join Digest::MD5.hexdigest(`tty`)
    end
  end
end
