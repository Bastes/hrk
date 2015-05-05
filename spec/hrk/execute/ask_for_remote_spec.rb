require "spec_helper"

RSpec.describe Hrk::Execute::AskForRemote do
  describe "#call" do
    let(:next_callee)  { double(Hrk::Execute::Command) }
    let(:env)          { double(Hrk::Env) }

    subject(:ask_for_remote) { Hrk::Execute::AskForRemote.new next_callee }

    let(:users_remote) { [%w(-a -r).sample, "remote-#{rand(0..9)}"] }
    let(:users_input)  { users_remote.join(" ") }

    before { allow(next_callee).to receive(:call) }
    before { allow(Hrk::Env).to receive(:new).and_return(env) }
    before { allow(ask_for_remote).to receive(:puts) }
    before { allow(STDIN).to receive(:gets).and_return(users_input) }
    before { ask_for_remote.call(*command) }

    context "there was no remote" do
      let(:command)      { %w(run console) }

      it { expect(ask_for_remote).to have_received(:puts) }
      it { expect(next_callee).to have_received(:call).with(*command, *users_remote) }
    end

    context "there was a remote" do
      let(:command) { %w(logs -t) + [%w(-a -r).sample, "remote-#{rand(0..9)}"] }

      it { expect(ask_for_remote).not_to have_received(:puts) }
      it { expect(STDIN).not_to have_received(:gets) }
      it { expect(next_callee).to have_received(:call).with(*command) }
    end
  end
end
