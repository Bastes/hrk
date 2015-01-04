require 'spec_helper'

RSpec.describe Hrk::Execute::Command do
  describe '#call' do
    subject(:command) { Hrk::Execute::Command.new }

    describe 'standard case (a remote, a command)' do
      let(:remote) { "remote-#{rand(1..9)}" }
      let(:args)   { %w(whatever that:may -b) }

      let(:heroku) { double("Hrk::Heroku") }
      before { allow(heroku).to receive(:call) }
      before { allow(Hrk::Heroku).to receive(:new).and_return(heroku) }

      before { command.call "#{remote}:", *args }

      it { expect(Hrk::Heroku).to have_received(:new).with(remote) }
      it { expect(heroku).to have_received(:call).with("whatever that:may -b") }
    end

    describe 'edge cases (no remote or improper remote)' do
      let(:other_args) { %w(something or-another) }
      it { expect { command.call }.to raise_error ArgumentError }
      it { expect { command.call "bad-remote", *other_args }.to raise_error ArgumentError }
      it { expect { command.call ":misplaced-marker", *other_args }.to raise_error ArgumentError }
      it { expect { command.call ":", *other_args }.to raise_error ArgumentError }
    end
  end
end
