require "spec_helper"

RSpec.describe Hrk::Heroku do
  describe "#call" do
    describe "the exec command ran" do
      def self.calling command, on_remote: %W(-r whatever-app), starts: [], and_outputs: ""
        describe "calling `#{command.join " "}` on remote #{on_remote}" do
          subject(:heroku) { Hrk::Heroku.new(*on_remote) }

          before { allow(heroku).to receive(:puts) }

          subject!(:result) { heroku.call(*command) }

          it { expect(heroku).to have_received(:exec).with(*starts) }
          it { expect(heroku).to have_received(:puts).with(and_outputs) }
        end
      end

      before { allow(heroku).to receive(:exec) }

      %w(-a -r).each do |opt|
        describe "(standard case, using #{opt})" do
          calling        %w(call rake db:rollback),
            on_remote:   %W(#{opt} demo),
            starts:      %W(heroku call rake db:rollback #{opt} demo),
            and_outputs: %Q(Executing `heroku call rake db:rollback #{opt} demo`...)
          calling        %w(call rake db:migrate),
            on_remote:   %W(#{opt} prod),
            starts:      %W(heroku call rake db:migrate #{opt} prod),
            and_outputs: %Q(Executing `heroku call rake db:migrate #{opt} prod`...)
          calling        %w(call console),
            on_remote:   %W(#{opt} staging),
            starts:      %W(heroku call console #{opt} staging),
            and_outputs: %Q(Executing `heroku call console #{opt} staging`...)
          calling        %w(logs -t),
            on_remote:   %W(#{opt} prod),
            starts:      %W(heroku logs -t #{opt} prod),
            and_outputs: %Q(Executing `heroku logs -t #{opt} prod`...)
          calling        %w(pgbackups:capture),
            on_remote:   %W(#{opt} demo),
            starts:      %W(heroku pgbackups:capture #{opt} demo),
            and_outputs: %Q(Executing `heroku pgbackups:capture #{opt} demo`...)
        end
      end

      describe "(edge case)" do
        subject(:heroku) { Hrk::Heroku.new(*%w(-r some-remote)) }

        before { allow(heroku).to receive(:puts) }
        before { allow(heroku).to receive(:exec) }

        specify "another remote is mentionned" do
          expect { heroku.call(*%w(run rake rake:db:migrate -r some-other-remote)) }.to raise_exception(Hrk::Heroku::ExplicitApplicationError)
          expect(heroku).not_to have_received(:puts)
          expect(heroku).not_to have_received(:exec)
        end
        specify "another app is mentionned" do
          expect { heroku.call(*%w(run rake rake:db:migrate -a different-app)) }.to raise_exception(Hrk::Heroku::ExplicitApplicationError)
          expect(heroku).not_to have_received(:puts)
          expect(heroku).not_to have_received(:exec)
        end
      end
    end

    describe "the result of the command" do
      subject(:heroku) { Hrk::Heroku.new(*%w(-r some-remote)) }
      before { expect(heroku).to receive(:exec).with(*%W(heroku some command -r some-remote)).and_return(exec_return) }
      before { expect(heroku).to receive(:puts) }

      context "the command result is truthy" do
        let(:exec_return) { true }

        it { expect(heroku.call(*%w(some command))).to be_truthy }
      end

      context "the command result is falsy" do
        let(:exec_return) { false }

        it { expect(heroku.call(*%w(some command))).to be_falsy }
      end
    end
  end
end
