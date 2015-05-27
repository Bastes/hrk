require "spec_helper"

RSpec.describe Hrk::Execute::Command do
  describe "#call" do
    subject(:command) { Hrk::Execute::Command.new }

    let(:arguments) { double(Hrk::Heroku) }

    before { allow(command.env).to receive(:remote=) }
    before { allow(command.env).to receive(:last_time=) }

    context "the arguments are alright" do
      [true, false].each do |the_result|
        context "and the command returns #{the_result}" do
          around { |b| Timecop.freeze Time.now, &b }

          let(:the_remote)  { %W(-#{%w(a r).sample} remote-#{rand(1..9)}) }
          before { allow(arguments).to receive(:call).and_return(the_result) }
          before { allow(arguments).to receive(:remote).and_return(the_remote) }

          subject!(:the_output) { command.call(arguments) }

          it { expect(the_output).to eq the_result }
          it { expect(command.env).to have_received(:remote=).with(the_remote) }
          it { expect(command.env).to have_received(:last_time=).with(Time.now) }
        end
      end
    end

    context "the command raises an error" do
      before { allow(arguments).to receive(:call).and_raise("any error") }

      before { expect(command.env).not_to receive(:remote=) }
      before { expect(command.env).not_to receive(:last_time=) }

      it { expect { command.call(arguments) }.to raise_error "any error" }
    end
  end
end
