require "spec_helper"

RSpec.describe Hrk::Execute::AskForRemote do
  describe "#call" do
    let(:next_callee)  { double(Hrk::Execute::Command) }
    let(:arguments)    { Hrk::Heroku.new the_command + the_remote }

    let(:the_command)  { %w(run rake db:migrate) }
    let(:users_remote) { [%w(-a -r).sample, "remote-#{rand(0..9)}"] }
    let(:users_input)  { users_remote.join(" ") }

    subject(:ask_for_remote) { Hrk::Execute::AskForRemote.new next_callee }

    before { allow(next_callee).   to receive(:call) }
    before { allow(ask_for_remote).to receive(:puts) }
    before { allow(ask_for_remote).to receive(:gets).and_return(users_input) }

    subject!(:the_result) { ask_for_remote.call(arguments) }

    context "there was no remote" do
      let(:the_remote) { [] }

      it { expect(ask_for_remote).to have_received(:puts) }
      it { expect(ask_for_remote).to have_received(:gets) }
      it { expect(next_callee).   to have_received(:call).with(Hrk::Heroku.new(the_command + users_remote)) }
    end

    context "there was a remote" do
      let(:the_remote) { %w{-r staging} }

      it { expect(ask_for_remote).not_to have_received(:puts) }
      it { expect(ask_for_remote).not_to have_received(:gets) }
      it { expect(next_callee).   to have_received(:call).with(arguments) }
    end
  end
end
