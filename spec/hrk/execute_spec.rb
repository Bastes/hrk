require 'spec_helper'

RSpec.describe Hrk::Execute do
  describe '.call' do
    let(:executer) { double }
    let(:args)     { %w(run rake db:migrate) }

    before { allow(Hrk::Execute).to receive(:executer).and_return(executer) }
    before { expect(executer).to receive(:call).with(*args).and_return(return_value) }

    [true, false].each do |value|
      describe "the executer returns #{value}" do
        let(:return_value) { value }

        it { expect(Hrk::Execute.call(*args)).to eq return_value }
      end
    end
  end
end
