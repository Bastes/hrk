require 'spec_helper'

RSpec.describe Hrk::Execute::RemoteDisplay do
  describe '#call' do
    let(:next_callee)        { double }
    let(:next_callee_result) { [true, false].sample }
    let(:remote)             { [%w(-a -r).sample, "demo#{rand(1..9)}"] }
    let(:there_be_a_remote)  { [true, false].sample }

    subject(:remote_display) { Hrk::Execute::RemoteDisplay.new(next_callee) }

    before { allow_any_instance_of(Hrk::Env).to receive(:remote?).and_return(there_be_a_remote) }
    before { allow_any_instance_of(Hrk::Env).to receive(:remote).and_return(remote) }
    before { allow(next_callee).to receive(:call).and_return(next_callee_result) }
    before { allow(remote_display).to receive(:puts) }

    subject!(:result) { remote_display.call(*args) }

    context 'there are no arguments' do
      let(:args) { [] }

      context 'but there is a remote' do
        let(:there_be_a_remote) { true }

        it { expect(result).to eq true }
        it { expect(remote_display).to have_received(:puts).with(remote.join(' ')) }
        it { expect(next_callee).not_to have_received(:call) }
      end

      context 'and no remote' do
        let(:there_be_a_remote) { false }

        it { expect(result).to eq false }
        it { expect(remote_display).not_to have_received(:puts) }
        it { expect(next_callee).not_to have_received(:call) }
      end
    end

    context 'there are arguments' do
      let(:args) { %W(what#{rand(1..9)} --will we --do -to -- the drunken --whaler?) }

      it { expect(result).to eq next_callee_result }
      it { expect(remote_display).not_to have_received(:puts) }
      it { expect(next_callee).to have_received(:call).with(*args) }
    end
  end
end
