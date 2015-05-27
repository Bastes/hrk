require "spec_helper"

RSpec.describe Hrk::Execute do
  describe ".call" do
    let(:executer) { double }
    let(:args)     { %w(run rake db:migrate) }

    before { allow(Hrk::Execute).to receive(:executer).and_return(executer) }

    [true, false].each do |value|
      describe "the executer returns #{value}" do
        before { expect(executer).to receive(:call).with(Hrk::Heroku.new(args)).and_return(value) }

        it { expect(Hrk::Execute.call(*args)).to eq value }
      end
    end
  end

  describe ".executer" do
    let(:error_trap)      { double(Hrk::Execute::ErrorTrap) }
    let(:heroku_detector) { double(Hrk::Execute::HerokuDetector) }
    let(:remote_display)  { double(Hrk::Execute::RemoteDisplay) }
    let(:help)            { double(Hrk::Execute::Help) }
    let(:remember)        { double(Hrk::Execute::Remember) }
    let(:ask_for_remote)  { double(Hrk::Execute::AskForRemote) }
    let(:command)         { double(Hrk::Execute::Command) }

    before { allow(Hrk::Execute::Command).       to receive(:new).and_return(command) }
    before { allow(Hrk::Execute::AskForRemote).  to receive(:new).with(command).and_return(ask_for_remote) }
    before { allow(Hrk::Execute::Remember).      to receive(:new).with(ask_for_remote).and_return(remember) }
    before { allow(Hrk::Execute::Help).          to receive(:new).with(remember).and_return(help) }
    before { allow(Hrk::Execute::RemoteDisplay). to receive(:new).with(help).and_return(remote_display) }
    before { allow(Hrk::Execute::HerokuDetector).to receive(:new).with(remote_display).and_return(heroku_detector) }
    before { allow(Hrk::Execute::ErrorTrap).     to receive(:new).with(heroku_detector).and_return(error_trap) }

    it { expect(Hrk::Execute.executer).to eq error_trap }
  end
end
