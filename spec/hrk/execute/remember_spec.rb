require "spec_helper"

RSpec.describe Hrk::Execute::Remember do
  describe '#call' do
    let(:next_callee) { double(Hrk::Execute::Command) }

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

      context "no remote in the args" do
        before { allow(env).to receive(:last_time?).and_return true }
        before { allow(env).to receive(:last_time).and_return(the_last_time) }

        context "last command ended less than 5 seconds ago" do
          let(:the_last_time) { Time.now - 4 }

          receiving %w(restart), it_should_pass_on: -> { %w(restart) + remote }
        end

        context "last command ended more than 5 seconds ago" do
          let(:the_last_time) { Time.now - 6 }
          before { allow(remember).to receive(:puts) }
          before { allow(STDIN).to receive(:gets).and_return(the_users_input) }

          ["y", "Y", "yes", "YES", "Yes"].each do |confirmation|
            context "and the user confirms with #{confirmation}" do
              let(:the_users_input) { "#{confirmation}\n" }

              receiving %w(restart), it_should_pass_on: -> { %w(restart) + remote }
            end
          end

          ["n", "N", "no", "NO", "No"].each do |abortion|
            context "and the user aborts with #{abortion}" do
              let(:the_users_input) { abortion }

              receiving %w(run rake db:migrate), it_should_pass_on: -> { %w(run rake db:migrate) }
            end
          end

          ["o", "whatever", "dude", "-r demo"].each do |gibbrish|
            context "and the user answers with #{gibbrish}" do
              let(:the_users_input) { gibbrish }

              it { expect { remember.call %w(run rails console) }.to raise_error Hrk::Execute::Remember::InvalidInputError }
            end
          end
        end
      end

      context "a remote in the args" do
        receiving %w(run rake some:task -r a-remote), it_should_pass_on: %w(run rake some:task -r a-remote)
        receiving %w(maintenance:on -a another-app), it_should_pass_on: %w(maintenance:on -a another-app)
      end

      context "part of a remote in the args" do
        receiving %w(run console -r), it_should_pass_on: %w(run console -r)
        receiving %w(maintenance:on -a), it_should_pass_on: %w(maintenance:on -a)
      end
    end
  end
end
