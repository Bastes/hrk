require 'spec_helper'

RSpec.describe Hrk::Execute::Command do
  describe '#call' do
    subject(:command) { Hrk::Execute::Command.new }

    let(:heroku) { double("Hrk::Heroku") }
    before { allow(heroku).to receive(:call) }
    before { allow(Hrk::Heroku).to receive(:new).and_return(heroku) }

    before { allow(command.env).to receive(:remote=) }

    context 'no remote was previously memorized' do
      before { allow(command.env).to receive(:remote?).and_return(nil) }

      describe 'standard case (a remote, a command)' do
        let(:remote) { "remote-#{rand(1..9)}" }
        let(:args)   { %w(whatever that:may -b) }

        %w(-a -r).each do |opt|
          context "using #{opt}" do
            [true, false].each do |result|
              context "when the command returns #{result}" do
                before { allow(heroku).to receive(:call).and_return(result) }

                it { expect(command.call(opt, remote, *args)).to eq result }
              end
            end

            describe 'interactions' do
              before { command.call(opt, remote, *args) }

              it { expect(Hrk::Heroku).to have_received(:new).with(opt, remote) }
              it { expect(heroku).to have_received(:call).with(*%w{whatever that:may -b}) }
              it { expect(command.env).to have_received(:remote=).with([opt, remote]) }
            end
          end
        end
      end

      describe 'edge cases (no remote, improper remote, too many remotes...)' do
        let(:other_args) { %W(something-#{rand(1..9)} -o r --another) }

        before { expect(heroku).not_to receive(:call) }
        before { expect(command.env).not_to receive(:remote=) }

        it { expect { command.call }.to raise_error ArgumentError }
        it { expect { command.call "parameterless-remote", *other_args }.to raise_error ArgumentError }
        it { expect { command.call(*other_args) }.to raise_error ArgumentError }
        it { expect { command.call(*other_args, '-r') }.to raise_error ArgumentError }
        it { expect { command.call(*other_args, '-a') }.to raise_error ArgumentError }
        it { expect { command.call '-r', 'remote', *other_args, '-r', 'other-remote' }.to raise_error ArgumentError }
        it { expect { command.call '-r', 'remote', *other_args, '-a', 'app' }.to raise_error ArgumentError }
        it { expect { command.call '-a', 'app', *other_args, '-a', 'other-app' }.to raise_error ArgumentError }
        it { expect { command.call '-r', 'something', *other_args, '-a', 'something-else' }.to raise_error ArgumentError }
      end
    end

    context 'a remote was previously memorized' do
      let(:previous_remote) { "ye-olde-remote#{rand(1..9)}" }
      before { allow(command.env).to receive(:remote).and_return(['-r', previous_remote]) }
      before { allow(command.env).to receive(:remote?).and_return(true) }

      describe 'standard case (a remote, a command)' do
        let(:remote) { "remote-#{rand(1..9)}" }
        let(:args)   { %w(whatever that:may -b) }

        [true, false].each do |result|
          describe "when the command returns #{result}" do
            before { allow(heroku).to receive(:call).and_return(result) }

            it { expect(command.call('-r', remote, *args)).to eq result }
          end
        end

        describe 'interactions' do
          before { command.call '-r', remote, *args }

          it { expect(Hrk::Heroku).to have_received(:new).with('-r', remote) }
          it { expect(heroku).to have_received(:call).with(*%w{whatever that:may -b}) }
          it { expect(command.env).to have_received(:remote=).with(['-r', remote]) }
        end
      end

      describe 'use previous remote' do
        let(:args)   { %w(whatever that:may -b) }

        [true, false].each do |result|
          describe "when the command returns #{result}" do
            before { allow(heroku).to receive(:call).and_return(result) }

            it { expect(command.call(*args)).to eq result }
          end
        end

        describe 'interactions' do
          before { command.call(*args) }

          it { expect(Hrk::Heroku).to have_received(:new).with('-r', previous_remote) }
          it { expect(heroku).to have_received(:call).with(*%w{whatever that:may -b}) }
        end
      end

      describe 'edge cases (improper remote, too many remotes...)' do
        let(:other_args) { %W(--whatever#{rand(1..9)} dude) }

        before { expect(heroku).not_to receive(:call) }
        before { expect(command.env).not_to receive(:remote=) }

        it { expect { command.call(*other_args, '-r') }.to raise_error ArgumentError }
        it { expect { command.call(*other_args, '-a') }.to raise_error ArgumentError }
        it { expect { command.call('-r', 'remote', *other_args, '-r', 'other-remote') }.to raise_error ArgumentError }
        it { expect { command.call('-r', 'remote', *other_args, '-a', 'app') }.to raise_error ArgumentError }
        it { expect { command.call('-a', 'app', *other_args, '-a', 'other-app') }.to raise_error ArgumentError }
        it { expect { command.call('-r', 'something', *other_args, '-a', 'something-else') }.to raise_error ArgumentError }
      end
    end
  end

  describe '#remote_and_command' do
    subject(:command) { Hrk::Execute::Command.new }

    context '(standard cases, arguments parsed)' do
      it { expect(command.remote_and_command(%w(run rake db:migrate))).to eq [nil, %w(run rake db:migrate)] }
      it { expect(command.remote_and_command(%w(restart))).to eq [nil, %w(restart)] }
      it { expect(command.remote_and_command(%w(-r demo restart))).to eq [%w(-r demo), %w(restart)] }
      it { expect(command.remote_and_command(%w(run rake db:migrate -r prod))).to eq [%w(-r prod), %w(run rake db:migrate)] }
      it { expect(command.remote_and_command(%w(some command -r test -i dont know --about))).to eq [%w(-r test), %w(some command -i dont know --about)] }
    end

    context '(edge cases, argument errors)' do
      it { expect { command.remote_and_command(%w(-r staging logs -t -r test)) }.to raise_error ArgumentError }
      it { expect { command.remote_and_command(%w(-a prod run rake db:migrate -r echo)) }.to raise_error ArgumentError }
      it { expect { command.remote_and_command(%w(run console -r demo -a app)) }.to raise_error ArgumentError }
      it { expect { command.remote_and_command(%w(-a one -a other maintenance:on)) }.to raise_error ArgumentError }
      it { expect { command.remote_and_command(%w(maintenance:off -a)) }.to raise_error ArgumentError }
      it { expect { command.remote_and_command(%w(restart -r)) }.to raise_error ArgumentError }
    end
  end
end
