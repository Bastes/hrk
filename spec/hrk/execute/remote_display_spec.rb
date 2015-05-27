require 'spec_helper'

RSpec.describe Hrk::Execute::RemoteDisplay do
  describe '#call' do
    let(:remote) { %w(-r staging) }

    before { allow_any_instance_of(Hrk::Env).to receive(:remote).and_return(remote) }
    before { allow(remote_display).to receive(:puts) }

    subject(:next_callee)    { double(Hrk::Execute::Command) }
    subject(:remote_display) { Hrk::Execute::RemoteDisplay.new(next_callee) }

    [true, false].each do |the_next_callee_returns|
      context "the next callee would return #{the_next_callee_returns}" do
        before { allow(next_callee).to receive(:call).and_return(the_next_callee_returns) }

        context 'there are no arguments' do
          let(:args) { [] }

          before { allow_any_instance_of(Hrk::Env).to receive(:remote?).and_return(there_was_a_remote) }

          subject!(:result) { remote_display.call(Hrk::Heroku.new(args)) }

          context 'but there is a remote' do
            let(:there_was_a_remote) { true }

            it { expect(result).to eq true }
            it { expect(remote_display).to have_received(:puts).with(remote.join(' ')) }
            it { expect(next_callee).not_to have_received(:call) }
          end

          context 'and no remote' do
            let(:there_was_a_remote) { false }

            it { expect(result).to eq false }
            it { expect(remote_display).not_to have_received(:puts) }
            it { expect(next_callee).not_to have_received(:call) }
          end
        end

        context 'there are arguments' do
          let(:args) { %W(what --will we --do -to -- the drunken --whaler?) }

          subject!(:result) { remote_display.call(Hrk::Heroku.new(args)) }

          it { expect(result).to eq the_next_callee_returns }
          it { expect(remote_display).not_to have_received(:puts) }
          it { expect(next_callee).to have_received(:call).with(args) }
        end
      end
    end
  end
end
