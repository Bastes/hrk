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

        [true, false].each do |result|
          describe "when the command returns #{result}" do
            before { allow(heroku).to receive(:call).and_return(result) }

            it { expect(command.call('-r', remote, *args)).to eq result }
          end
        end

        describe 'interactions' do
          before { command.call '-r', remote, *args }

          it { expect(Hrk::Heroku).to have_received(:new).with("-r #{remote}") }
          it { expect(heroku).to have_received(:call).with("whatever that:may -b") }
          it { expect(command.env).to have_received(:remote=).with("-r #{remote}") }
        end
      end

      describe 'edge cases (no remote or improper remote)' do
        let(:other_args) { %W(something-#{rand(1..9)} or-another) }

        before { expect(heroku).not_to receive(:call) }
        before { expect(command.env).not_to receive(:remote=) }

        it { expect { command.call }.to raise_error ArgumentError }
        it { expect { command.call "parameterless-remote", *other_args }.to raise_error ArgumentError }
        it { expect { command.call *other_args, '-r' }.to raise_error ArgumentError }
      end
    end

    context 'a remote was previously memorized' do
      let(:previous_remote) { "-r ye-olde-remote#{rand(1..9)}" }
      before { allow(command.env).to receive(:remote).and_return(previous_remote) }
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

          it { expect(Hrk::Heroku).to have_received(:new).with("-r #{remote}") }
          it { expect(heroku).to have_received(:call).with("whatever that:may -b") }
          it { expect(command.env).to have_received(:remote=).with("-r #{remote}") }
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
          before { command.call *args }

          it { expect(Hrk::Heroku).to have_received(:new).with(previous_remote) }
          it { expect(heroku).to have_received(:call).with("whatever that:may -b") }
        end
      end
    end
  end
end
