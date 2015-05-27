require "spec_helper"

RSpec.describe Hrk::Execute::Remember do
  describe '#call' do
    subject(:next_callee) { double(Hrk::Execute::Command) }
    subject(:remember)    { Hrk::Execute::Remember.new next_callee }
    subject(:env)         { double(Hrk::Env) }

    before { allow(next_callee).to receive(:call) }
    before { allow(Hrk::Env).   to receive(:new).and_return(env) }

    def self.receiving args, it_passes: []
      context "receiving #{args.join " "}" do
        let(:arguments)   { Hrk::Heroku.new(args) }
        subject!(:result) { remember.call(arguments) }

        it { expect(next_callee).to have_received(:call).with(it_passes) }
      end
    end

    context "no remote memorized" do
      before { allow(env).to receive(:remote?).and_return(false) }
      before { allow(env).to receive(:remote).and_return(nil) }

      context "a remote in the args" do
        receiving %w(logs -t -r demo),                       it_passes: %w(logs -t -r demo)
        receiving %w(run rake db:migrate -a that-one-cloud), it_passes: %w(run rake db:migrate -a that-one-cloud)
      end

      context "no remote in the args" do
        receiving %w(run rake db:rollback), it_passes: %w(run rake db:rollback)
        receiving %w(run console),          it_passes: %w(run console)
      end

      context "part of a remote in the args" do
        receiving %w(maintenance:off -r), it_passes: %w(maintenance:off -r)
        receiving %w(logs -a),            it_passes: %w(logs -a)
      end
    end

    context "a remote memorized" do
      let(:remote) { %w(-r production) }
      before { allow(env).to receive(:remote?).and_return(true) }
      before { allow(env).to receive(:remote).and_return(remote) }

      context "no remote in the args" do
        before { allow(env).to receive(:last_time?).and_return true }
        before { allow(env).to receive(:last_time).and_return(the_last_time) }

        context "last command ended less than 5 seconds ago" do
          let(:the_last_time) { Time.now - 4 }

          receiving %w(restart), it_passes: %w(restart -r production)
        end

        context "last command ended more than 5 seconds ago" do
          let(:the_last_time) { Time.now - 6 }
          before { allow(remember).to receive(:puts) }
          before { allow(remember).to receive(:gets).and_return(the_users_input) }

          ["y", "Y", "yes", "YES", "Yes"].each do |confirmation|
            context "and the user confirms with #{confirmation}" do
              let(:the_users_input) { "#{confirmation}\n" }

              receiving %w(logs --tail), it_passes: %w(logs --tail -r production)
            end
          end

          ["n", "N", "no", "NO", "No"].each do |abortion|
            context "and the user aborts with #{abortion}" do
              let(:the_users_input) { abortion }

              receiving %w(run rake db:migrate), it_passes: %w(run rake db:migrate)
            end
          end

          ["o", "whatever", "dude", "-r demo"].each do |gibbrish|
            context "and the user answers with #{gibbrish}" do
              let(:the_users_input) { gibbrish }

              it { expect { remember.call Hrk::Heroku.new(%w(run rails console)) }.to raise_error Hrk::Execute::Remember::InvalidInputError }
            end
          end
        end
      end

      context "a remote in the args" do
        receiving %w(run rake some:task -r a-remote), it_passes: %w(run rake some:task -r a-remote)
        receiving %w(maintenance:on -a another-app),  it_passes: %w(maintenance:on -a another-app)
      end

      context "part of a remote in the args" do
        receiving %w(run console -r),    it_passes: %w(run console -r)
        receiving %w(maintenance:on -a), it_passes: %w(maintenance:on -a)
      end
    end
  end
end
