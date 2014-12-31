require 'spec_helper'

RSpec.describe Hrk::Command do
  describe '#call' do
    let(:remote) { "remote-#{rand(1..9)}" }
    let(:args)   { ["whatever", "that:may", "-b"] }

    let(:heroku) { double("Hrk::Heroku") }
    before { allow(heroku).to receive(:call) }
    before { allow(Hrk::Heroku).to receive(:new).with(remote).and_return(heroku) }

    before { Hrk::Command.new.call remote, *args }

    it { expect(heroku).to have_received(:call).with("whatever that:may -b") }
  end
end
