require "spec_helper"

RSpec.describe Hrk::Execute::IO do
  subject(:an_instance) { Object.new.tap { |o| o.extend Hrk::Execute::IO } }

  describe "#puts" do
    let(:argument) { "Some stupid output" }
    before         { allow(STDOUT).to receive :puts }

    subject!(:the_result) { an_instance.puts argument }

    it { expect(STDOUT).to have_received(:puts).with(argument) }
  end

  describe "#gets" do
    let(:the_input) { "Whatever the user inputs\n" }
    before          { allow(STDIN).to receive(:gets).and_return the_input }

    subject!(:the_result) { an_instance.gets }
    it { expect(the_result).to eq the_input }
  end
end
