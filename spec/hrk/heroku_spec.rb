require "spec_helper"

RSpec.describe Hrk::Heroku do
  describe Hrk::Heroku::Arguments do
    describe "#remote, #command" do
      def self.given arguments_given, the_remote_is: nil, the_command_is: nil
        context "given #{arguments_given}" do
          subject(:arguments) { Hrk::Heroku::Arguments.new(arguments_given) }

          it { expect(arguments.remote).to  eq the_remote_is }
          it { expect(arguments.command).to eq the_command_is }
        end
      end

      given %w(-r demo),
        the_remote_is:  %w(-r demo),
        the_command_is: []
      given %w(-a app2),
        the_remote_is:  %w(-a app2),
        the_command_is: []
      given %w(),
        the_remote_is:  nil,
        the_command_is: []
      given %w(-r test run rake db:migrate),
        the_remote_is:  %w(-r test),
        the_command_is: %w(run rake db:migrate)
      given %w(logs --tail -a my-awesome-app),
        the_remote_is:  %w(-a my-awesome-app),
        the_command_is: %w(logs --tail)
      given %w(pg:copy DATABASE_URL HEROKU_POSTGRESQL_PINK -a sushi --confirm sushi),
        the_remote_is:  %w(-a sushi),
        the_command_is: %w(pg:copy DATABASE_URL HEROKU_POSTGRESQL_PINK --confirm sushi)
    end

    describe "#to_a, #to_ary" do
      def self.given arguments_given, the_array_is: nil
        context "given #{arguments_given}" do
          subject(:arguments) { Hrk::Heroku::Arguments.new(arguments_given) }

          it { expect(arguments.to_a).to eq the_array_is }
          it { expect(arguments).to      eq the_array_is }
        end
      end

      given [],                         the_array_is: []
      given %w(-r demo),                the_array_is: %w(-r demo)
      given %w(run rake db:migrate),    the_array_is: %w(run rake db:migrate)
      given %w(restart -a prod),        the_array_is: %w(restart -a prod)
      given %w(-r staging logs --tail), the_array_is: %w(logs --tail -r staging)
    end

    describe "#call" do
      def self.calling the_arguments , starts: [], and_outputs: ""
        describe "executing `#{the_arguments}`" do
          subject(:arguments) { Hrk::Heroku::Arguments.new(the_arguments) }

          before { allow(arguments).to receive(:puts) }
          before { allow(arguments).to receive(:exec) }

          subject!(:result) { arguments.call }

          it { expect(arguments).to have_received(:exec).with(starts) }
          it { expect(arguments).to have_received(:puts).with(and_outputs) }
        end
      end

      %w(-a -r).each do |opt|
        describe "(standard case, using #{opt})" do
          calling        %W(run rake db:rollback #{opt} demo),
            starts:      %W(heroku run rake db:rollback #{opt} demo),
            and_outputs: %Q(Executing `heroku run rake db:rollback #{opt} demo`...)
          calling        %W(run rake db:migrate #{opt} prod),
            starts:      %W(heroku run rake db:migrate #{opt} prod),
            and_outputs: %Q(Executing `heroku run rake db:migrate #{opt} prod`...)
          calling        %W(run console #{opt} staging),
            starts:      %W(heroku run console #{opt} staging),
            and_outputs: %Q(Executing `heroku run console #{opt} staging`...)
          calling        %W(logs -t #{opt} prod),
            starts:      %W(heroku logs -t #{opt} prod),
            and_outputs: %Q(Executing `heroku logs -t #{opt} prod`...)
          calling        %W(pgbackups:capture #{opt} demo),
            starts:      %W(heroku pgbackups:capture #{opt} demo),
            and_outputs: %Q(Executing `heroku pgbackups:capture #{opt} demo`...)
        end
      end

      describe "(edge case)" do
        subject(:arguments) { Hrk::Heroku::Arguments.new(the_arguments) }

        before { allow(arguments).to receive(:puts) }
        before { allow(arguments).to receive(:exec) }

        describe "another remote is mentionned" do
          let(:the_arguments) { %w(-r some-remote run rake rake:db:migrate -r some-other-remote) }

          specify do
            expect { arguments.call }.to raise_exception(Hrk::Heroku::ExplicitApplicationError)
            expect(arguments).not_to have_received(:puts)
            expect(arguments).not_to have_received(:exec)
          end
        end

        describe "another app is mentionned" do
          let(:the_arguments) { %w(-r some-remote run rake rake:db:migrate -a different-app) }

          specify do
            expect { arguments.call }.to raise_exception(Hrk::Heroku::ExplicitApplicationError)
            expect(arguments).not_to have_received(:puts)
            expect(arguments).not_to have_received(:exec)
          end
        end
      end

      describe "the result of the command" do
        subject(:arguments) { Hrk::Heroku::Arguments.new(%w(-r some-remote some command)) }

        before { expect(arguments).to receive(:exec).with(%W(heroku some command -r some-remote)).and_return(exec_return) }
        before { expect(arguments).to receive(:puts) }

        context "the command result is truthy" do
          let(:exec_return) { true }

          it { expect(arguments.call).to be_truthy }
        end

        context "the command result is falsy" do
          let(:exec_return) { false }

          it { expect(arguments.call).to be_falsy }
        end
      end
    end
  end

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
          calling        %w(run rake db:rollback),
            on_remote:   %W(#{opt} demo),
            starts:      %W(heroku run rake db:rollback #{opt} demo),
            and_outputs: %Q(Executing `heroku run rake db:rollback #{opt} demo`...)
          calling        %w(run rake db:migrate),
            on_remote:   %W(#{opt} prod),
            starts:      %W(heroku run rake db:migrate #{opt} prod),
            and_outputs: %Q(Executing `heroku run rake db:migrate #{opt} prod`...)
          calling        %w(run console),
            on_remote:   %W(#{opt} staging),
            starts:      %W(heroku run console #{opt} staging),
            and_outputs: %Q(Executing `heroku run console #{opt} staging`...)
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
