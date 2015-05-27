require "spec_helper"

RSpec.describe Hrk::Execute::ErrorTrap do
  describe "#call" do
    subject(:next_callee) { double(Hrk::Execute::Command) }
    subject(:error_trap) { Hrk::Execute::ErrorTrap.new(next_callee) }

    context "no --hrk-testing option" do
      let(:args) { Hrk::Heroku.new(%W(-a b --cd)) }

      context "no exception is raised" do
        [true, false].each do |result_obtained|
          context "and the result is #{result_obtained}" do
            before { allow(next_callee).to receive(:call).and_return(result_obtained) }

            subject!(:result) { error_trap.call(args) }

            it { expect(result).to eq result_obtained }
            it { expect(next_callee).to have_received(:call).with(args) }
          end
        end
      end

      context "an exception is raised" do
        let(:exception) { ArgumentError.new "+++ Melon Melon Melon +++" }

        before { allow(next_callee).to receive(:call).and_raise(exception) }
        before { allow(error_trap).to receive(:puts) }

        it { expect { error_trap.call(args) }.not_to raise_exception }
        it { expect(error_trap.call(args)).to eq false }

        context "interactions" do
          before { error_trap.call(args) }

          it { expect(error_trap).to have_received(:puts).with("Error: #{exception.message}") }
        end
      end
    end

    context "an --hrk-testing option" do
      let(:args) { Hrk::Heroku.new(%w(-r remote --hrk-testing logs -t)) }

      context "no exception is raised" do
        [true, false].each do |result_obtained|
          context "and the result is #{result_obtained}" do
            before { allow(next_callee).to receive(:call).and_return(result_obtained) }

            subject!(:result) { error_trap.call(args) }

            it { expect(result).to eq result_obtained }
            it { expect(next_callee).to have_received(:call).with(Hrk::Heroku.new(%w(-r remote logs -t))) }
          end
        end
      end

      context "an exception is raised" do
        let(:exception) { ArgumentError.new "Out of cheese error" }

        before { allow(next_callee).to receive(:call).with(Hrk::Heroku.new(%w(-r remote logs -t))).and_raise(exception) }
        before { allow(error_trap).to receive(:puts) }

        it { expect { error_trap.call(args) }.to raise_exception exception }

        context "interactions" do
          before { error_trap.call(args) rescue nil }

          it { expect(error_trap).not_to have_received(:puts) }
        end
      end
    end
  end
end
