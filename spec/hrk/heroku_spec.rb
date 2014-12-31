require 'spec_helper'

RSpec.describe Hrk::Heroku do
  describe '#call' do
    describe 'the system command ran' do
      def self.calling command, on_remote: 'whatever-app', starts: ''
        describe "calling '#{command}' on remote '#{on_remote}', system" do
          subject(:heroku) { Hrk::Heroku.new(on_remote) }

          before { heroku.call command }

          it { expect(heroku).to have_received(:system).with(starts) }
        end
      end

      before { allow(heroku).to receive(:system) }

      calling 'call rake db:rollback', on_remote: 'demo',    starts: 'heroku call rake db:rollback -r demo'
      calling 'call rake db:migrate',  on_remote: 'prod',    starts: 'heroku call rake db:migrate -r prod'
      calling 'call console',          on_remote: 'staging', starts: 'heroku call console -r staging'
      calling 'logs -t',               on_remote: 'prod',    starts: 'heroku logs -t -r prod'
      calling 'pgbackups:capture',     on_remote: 'demo',    starts: 'heroku pgbackups:capture -r demo'
    end

    describe 'the result of the command' do
      subject(:heroku) { Hrk::Heroku.new('some-remote') }
      before { allow(heroku).to receive(:system).with('heroku some command -r some-remote').and_return(system_returns) }

      context 'the command result is truthy' do
        let(:system_returns) { true }

        it { expect(heroku.call('some command')).to be_truthy }
      end

      context 'the command result is falsy' do
        let(:system_returns) { false }

        it { expect(heroku.call('some command')).to be_falsy }
      end
    end
  end
end
