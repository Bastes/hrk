require 'spec_helper'

RSpec.describe Hrk::Execute::HerokuDetector do
  describe '#call' do
    let(:next_callee) { double(Hrk::Execute::Command) }

    subject(:heroku_detector) { Hrk::Execute::HerokuDetector.new(next_callee) }

    [true, false].each do |next_callee_returns|
      context "the next_callee would return #{next_callee_returns.inspect}" do
        let(:args) { %W(-s ome dumb --arguments#{rand(1..9)}) }

        before { allow(next_callee).to receive(:call).and_return(next_callee_returns) }
        before { allow(heroku_detector).to receive(:heroku_present?).and_return(heroku_exist) }
        before { allow(heroku_detector).to receive(:puts) }

        subject!(:result) { heroku_detector.call(args) }

        context 'heroku is here' do
          let!(:heroku_exist) { true }

          it { expect(result).to eq next_callee_returns }
          it { expect(next_callee).to have_received(:call).with(args) }
          it { expect(heroku_detector).not_to have_received(:puts) }
        end

        context 'heroku is not here' do
          let!(:heroku_exist) { false }

          it { expect(result).to be_falsy }
          it { expect(next_callee).not_to have_received(:call) }
          it { expect(heroku_detector).to have_received(:puts) }
        end
      end
    end
  end
end
