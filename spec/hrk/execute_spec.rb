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

  describe '.executer' do
    let(:error_trap)      { double(Hrk::Execute::ErrorTrap) }
    let(:heroku_detector) { double(Hrk::Execute::HerokuDetector) }
    let(:remote_display)  { double(Hrk::Execute::RemoteDisplay) }
    let(:help)            { double(Hrk::Execute::Help) }
    let(:command)         { double(Hrk::Execute::Command) }

    before { allow(Hrk::Execute::Command).to receive(:new).and_return(command) }
    before { allow(Hrk::Execute::Help).to receive(:new).with(command).and_return(help) }
    before { allow(Hrk::Execute::RemoteDisplay).to receive(:new).with(help).and_return(remote_display) }
    before { allow(Hrk::Execute::HerokuDetector).to receive(:new).with(remote_display).and_return(heroku_detector) }
    before { allow(Hrk::Execute::ErrorTrap).to receive(:new).with(heroku_detector).and_return(error_trap) }

    it { expect(Hrk::Execute.executer).to eq error_trap }
  end
end
