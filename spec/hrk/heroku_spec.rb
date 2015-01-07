require 'spec_helper'

RSpec.describe Hrk::Heroku do
  describe '#call' do
    describe 'the system command ran' do
      def self.calling command, on_remote: %W(-r whatever-app), starts: ''
        describe "calling '#{command.join ' '}' on remote '#{on_remote}', system" do
          subject(:heroku) { Hrk::Heroku.new(*on_remote) }

          before { heroku.call *command }

          it { expect(heroku).to have_received(:system).with(*starts) }
        end
      end

      before { allow(heroku).to receive(:system) }

      %w(-a -r).each do |opt|
        describe "(standard case, using #{opt})" do
          calling %w(call rake db:rollback), on_remote: %W(#{opt} demo),    starts: %W(heroku call rake db:rollback #{opt} demo)
          calling %w(call rake db:migrate),  on_remote: %W(#{opt} prod),    starts: %W(heroku call rake db:migrate #{opt} prod)
          calling %w(call console),          on_remote: %W(#{opt} staging), starts: %W(heroku call console #{opt} staging)
          calling %w(logs -t),               on_remote: %W(#{opt} prod),    starts: %W(heroku logs -t #{opt} prod)
          calling %w(pgbackups:capture),     on_remote: %W(#{opt} demo),    starts: %W(heroku pgbackups:capture #{opt} demo)
        end
      end

      describe '(edge case)' do
        subject(:heroku) { Hrk::Heroku.new(*%w(-r some-remote)) }

        it { expect { heroku.call(*%w(run rake rake:db:migrate -r some-other-remote)) }.to raise_exception(Hrk::Heroku::ExplicitApplicationError) }
        it { expect { heroku.call(*%w(run rake rake:db:migrate -a different-app)) }.to raise_exception(Hrk::Heroku::ExplicitApplicationError) }
      end
    end

    describe 'the result of the command' do
      subject(:heroku) { Hrk::Heroku.new(*%w(-r some-remote)) }
      before { allow(heroku).to receive(:system).with(*%W(heroku some command -r some-remote)).and_return(system_returns) }

      context 'the command result is truthy' do
        let(:system_returns) { true }

        it { expect(heroku.call(*%w(some command))).to be_truthy }
      end

      context 'the command result is falsy' do
        let(:system_returns) { false }

        it { expect(heroku.call(*%w(some command))).to be_falsy }
      end
    end
  end
end
