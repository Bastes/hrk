require 'spec_helper'

RSpec.describe Hrk::Execute::ErrorTrap do
  describe '#call' do
    let(:next_callee) { double }
    let(:args)   { %W(-a b#{rand(1..9)} --cd) }

    subject(:error_trap) { Hrk::Execute::ErrorTrap.new(next_callee) }

    describe 'no exception is raised' do
      let(:expected_result) { [true, false].sample }

      before { allow(next_callee).to receive(:call).and_return(expected_result) }

      subject!(:result) { error_trap.call(*args) }

      it { expect(result).to eq expected_result }
      it { expect(next_callee).to have_received(:call).with(*args) }
    end

    describe 'an exception is raised' do
      let(:exception) { ArgumentError.new "blah #{rand(1..9)} blah" }

      before { allow(next_callee).to receive(:call).and_raise(exception) }
      before { allow(error_trap).to receive(:puts) }

      it { expect { error_trap.call(*args) }.not_to raise_exception }
      it { expect(error_trap.call(*args)).to eq false }

      describe 'interactions' do
        before { error_trap.call(*args) }

        it { expect(error_trap).to have_received(:puts).with("Error: #{exception.message}") }
      end
    end
  end
end
