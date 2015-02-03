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

    def schedule_cleanup!
      unless cleanup_scheduled?
        self.pid = fork do
          Signal.trap('INT') {}
          at_exit { cleanup! }
          while(true) do
            `tty`
            exit if $? != 0
            sleep 1
          end
        end
      end
    end

    def cleanup!
      remote_path.delete if remote_path.exist?
      pid_path.delete    if pid_path.exist?
    end

    def remote= args
      schedule_cleanup!
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

    def cleanup_scheduled?
      begin
        pid? && Process.kill(0, pid)
      rescue Errno::ESRCH
        false
      end
    end

    def pid
      pid_path.read.to_i if pid?
    end

    def pid?
      pid_path.exist?
    end

    def pid= value
      pid_path.write(value)
    end

    def pid_path
      tmp_path.join "#{tty_digest}.pid"
    end
  end
end
