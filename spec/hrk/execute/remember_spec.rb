require "spec_helper"

RSpec.describe Hrk::Execute::Remember do
  describe '#call' do
    let(:next_callee) { double }

    subject(:remember) { Hrk::Execute::Remember.new next_callee }
    subject(:env) { double(Hrk::Env) }

    before { allow(next_callee).to receive(:call) }
    before { allow(Hrk::Env).to receive(:new).and_return(env) }

    def self.receiving args, it_should_pass_on: []
      context "receiving #{args.join " "}" do
        let(:what_it_should_pass_on) do
          if it_should_pass_on.respond_to?(:call)
            instance_exec(&it_should_pass_on)
          else
            it_should_pass_on
          end
        end
        subject!(:result) { remember.call(*args) }

        it { expect(next_callee).to have_received(:call).with(*what_it_should_pass_on) }
      end
    end

    context "no remote memorized" do
      before { allow(env).to receive(:remote?).and_return(false) }
      before { allow(env).to receive(:remote).and_return(nil) }

      context "a remote in the args" do
        receiving %w(logs -t -r demo), it_should_pass_on: %w(logs -t -r demo)
        receiving %w(run rake db:migrate -a that-one-cloud), it_should_pass_on: %w(run rake db:migrate -a that-one-cloud)
      end

      context "no remote in the args" do
        receiving %w(run rake db:rollback), it_should_pass_on: %w(run rake db:rollback)
        receiving %w(run console), it_should_pass_on: %w(run console)
      end

      context "part of a remote in the args" do
        receiving %w(maintenance:off -r), it_should_pass_on: %w(maintenance:off -r)
        receiving %w(logs -a), it_should_pass_on: %w(logs -a)
      end
    end

    context "a remote memorized" do
      let(:remote) { [%w(-r -a).sample, %w(demo staging prod test app).sample] }
      before { allow(env).to receive(:remote?).and_return(true) }
      before { allow(env).to receive(:remote).and_return(remote) }

      context "a remote in the args" do
        receiving %w(run rake some:task -r a-remote), it_should_pass_on: %w(run rake some:task -r a-remote)
        receiving %w(maintenance:on -a another-app), it_should_pass_on: %w(maintenance:on -a another-app)
      end

      context "no remote in the args" do
        receiving %w(restart), it_should_pass_on: -> { %w(restart) + remote }
      end

      context "part of a remote in the args" do
        receiving %w(run console -r), it_should_pass_on: %w(run console -r)
        receiving %w(maintenance:on -a), it_should_pass_on: %w(maintenance:on -a)
      end
    end
  end
end
