require 'spec_helper'

RSpec.describe Hrk::Env do
  subject(:env) { Hrk::Env.new }

  shared_context 'fake socket_path' do
    let(:socket_path) { double(Pathname) }

    before { allow(socket_path).to receive(:delete) }
    before { allow(socket_path).to receive(:write) }
    before { allow(env).to receive(:socket_path).and_return socket_path }
  end

  describe '#remote=' do
    include_context 'fake socket_path'

    let(:remote_arg)   { "-#{%w(a r).sample}" }
    let(:remote_name)  { "remote##{rand(1..9)}" }

    before { allow(env).to receive(:remote).and_return(previous_remote) }

    before { env.remote = [remote_arg, remote_name] }

    context 'no previous remote' do
      let(:previous_remote) { nil }

      it { expect(socket_path).to have_received(:write).with("#{remote_arg} #{remote_name}") }
    end

    context 'the previous remote is different' do
      let(:previous_remote) { ['-r', 'previous'] }

      it { expect(socket_path).to have_received(:write).with("#{remote_arg} #{remote_name}") }
    end

    context 'the previous remote is identical' do
      let(:previous_remote) { [remote_arg, remote_name] }

      it { expect(socket_path).not_to have_received(:write) }
    end
  end

  describe '#remote' do
    include_context 'fake socket_path'

    before { allow(socket_path).to receive(:exist?).and_return it_pre_exist }
    before { allow(socket_path).to receive(:read).and_return remote }

    context 'no remote file exists' do
      let(:it_pre_exist) { false }
      let(:remote)       { nil }

      it { expect(env.remote).to eq nil }
    end

    context 'the remote file exists' do
      let(:it_pre_exist) { true }
      let(:remote_arg)   { "-#{%w(a r).sample}" }
      let(:remote_name)  { "remote##{rand(1..9)}" }
      let(:remote)       { "#{remote_arg} #{remote_name}" }

      it { expect(env.remote).to eq [remote_arg, remote_name] }
    end
  end

  describe '#remote?' do
    include_context 'fake socket_path'

    before { allow(socket_path).to receive(:exist?).and_return it_pre_exist }

    context 'the remote file exists' do
      let(:it_pre_exist) { true }

      it { expect(env.remote?).to eq true }
    end

    context 'the remote file does not exist' do
      let(:it_pre_exist) { false }

      it { expect(env.remote?).to eq false }
    end
  end

  describe '#tmp_path' do
    let(:some_dir) { Pathname.new "/some#{rand(1..9)}/fake/dir" }
    before { allow(env).to receive(:tmp_dir).and_return(some_dir) }
    before { allow_any_instance_of(Pathname).to receive(:exist?).and_return(it_pre_exist) }
    before { allow(FileUtils).to receive(:mkdir_p) }

    subject!(:path) { env.tmp_path }

    context 'the path did not already exist' do
      let(:it_pre_exist) { false }

      it { expect(path).to eq Pathname.new("#{some_dir}/hrk") }
      it { expect(FileUtils).to have_received(:mkdir_p).with(path) }
    end

    context 'the path did already exist' do
      let(:it_pre_exist) { true }

      it { expect(path).to eq Pathname.new("#{some_dir}/hrk") }
      it { expect(FileUtils).not_to have_received(:mkdir_p) }
    end
  end

  describe '#tmp_dir' do
    let(:tmpdir)          { "/another/silly/path#{rand(1..9)}" }
    before { allow(Dir).to receive(:tmpdir).and_return(tmpdir) }
    before { allow(ENV).to receive(:[]).with('XDG_RUNTIME_DIR').and_return(xdg_runtime_dir) }
    context 'there is an XDG_RUNTIME_DIR in the ENV' do
      let(:xdg_runtime_dir) { "/yet_again/a#{rand(1..9)}/folder" }

      it { expect(env.tmp_dir).to eq Pathname.new(xdg_runtime_dir) }
    end

    context 'there is no XDG_RUNTIME_DIR in the ENV' do
      let(:xdg_runtime_dir) { nil }

      it { expect(env.tmp_dir).to eq Pathname.new(tmpdir) }
    end
  end

  describe '#socket_path' do
    let(:some_dir) { Pathname.new "/and#{rand(1..9)}/another_/dir" }
    let(:tty)      { "/dev/pts/#{rand(1..9)}" }

    before { allow(env).to receive(:tmp_path).and_return(Pathname.new(some_dir)) }
    before { allow(env).to receive(:`).and_return(tty) }

    it { expect(env.socket_path).to eq Pathname.new("#{some_dir}/#{Digest::MD5.hexdigest(tty)}") }
  end
end
