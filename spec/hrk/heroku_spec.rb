require "spec_helper"

RSpec.describe Hrk::Heroku do
  describe "#remote, #command" do
    def self.given arguments_given, the_remote_is: nil, the_command_is: nil
      context "given #{arguments_given}" do
        subject(:arguments) { Hrk::Heroku.new(arguments_given) }

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
    given %w(-a),
      the_remote_is:  %w(-a),
      the_command_is: []
    given %w(run rails c -r),
      the_remote_is:  %w(-r),
      the_command_is: %w(run rails c)
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

  describe "#empty?" do
    it { expect(Hrk::Heroku.new([]).empty?).to be_truthy }
    it { expect(Hrk::Heroku.new(%w(-r omed)).empty?).to be_falsy }
    it { expect(Hrk::Heroku.new(%w(-a drop)).empty?).to be_falsy }
    it { expect(Hrk::Heroku.new(%w(run rake db:migrate)).empty?).to be_falsy }
  end

  describe "#include?" do
    it { expect(Hrk::Heroku.new([]).include? "whatever").to be_falsy }
    it { expect(Hrk::Heroku.new(%w(-it has --some-option or --other)).include? "--some-option").to be_truthy }
    it { expect(Hrk::Heroku.new(%w(there --are options)).include? "--some-option").to be_falsy }
    it { expect(Hrk::Heroku.new(%w(there --are options)).include? "options").to be_truthy }
  end

  describe "#-" do
    it { expect(Hrk::Heroku.new(%w(--call-me blah please -guys)) - ["blah"]).to eql Hrk::Heroku.new(%w(--call-me please -guys)) }
    it { expect(Hrk::Heroku.new(%w(--call-me blah please -guys)) - ["self-doubt"]).to eql Hrk::Heroku.new(%w(--call-me blah please -guys)) }
  end

  describe "#to_a, #to_ary" do
    def self.given arguments_given, the_array_is: nil
      context "given #{arguments_given}" do
        subject(:arguments) { Hrk::Heroku.new(arguments_given) }

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

  describe "#on_remote" do
    context "the original had no remote" do
      subject(:original) { Hrk::Heroku.new(%w(logs -t))  }
      subject(:result)   { original.on_remote %w(-r other-remote) }

      it { expect(result.remote).to  eq %w(-r other-remote) }
      it { expect(result.command).to eq %w(logs -t) }
    end

    context "the original had a remote" do
      subject(:original) { Hrk::Heroku.new(%w(run rails c -r demo-remote))  }
      subject(:result)   { original.on_remote %w(-a super-app) }

      it { expect(result.remote).to  eq %w(-a super-app) }
      it { expect(result.command).to eq %w(run rails c) }
    end
  end

  describe "#call" do
    def self.calling the_arguments , starts: [], and_outputs: ""
      describe "executing `#{the_arguments}`" do
        subject(:arguments) { Hrk::Heroku.new(the_arguments) }

        before { allow(arguments).to receive(:puts) }
        before { allow(arguments).to receive(:exec) }

        subject!(:result) { arguments.call }

        it { expect(arguments).to have_received(:exec).with(*starts) }
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

    describe "edge cases" do
      subject(:arguments) { Hrk::Heroku.new(the_arguments) }

      before { allow(arguments).to receive(:puts) }
      before { allow(arguments).to receive(:exec) }

      describe "another remote is mentionned" do
        let(:the_arguments) { %w(-r some-remote run rake rake:db:migrate -r some-other-remote) }

        specify do
          expect { arguments.call }.to raise_exception(Hrk::Heroku::TooManyRemotesError)
          expect(arguments).not_to have_received(:puts)
          expect(arguments).not_to have_received(:exec)
        end
      end

      describe "another app is mentionned" do
        let(:the_arguments) { %w(-r some-remote run rake rake:db:migrate -a different-app) }

        specify do
          expect { arguments.call }.to raise_exception(Hrk::Heroku::TooManyRemotesError)
          expect(arguments).not_to have_received(:puts)
          expect(arguments).not_to have_received(:exec)
        end
      end

      describe "no remote nor app is mentionned" do
        let(:the_arguments) { %w(run rake some:important --task) }

        specify do
          expect { arguments.call }.to raise_exception(Hrk::Heroku::NoRemoteError)
          expect(arguments).not_to have_received(:puts)
          expect(arguments).not_to have_received(:exec)
        end
      end
    end

    describe "the result of the command" do
      subject(:arguments) { Hrk::Heroku.new(%w(-r some-remote some command)) }

      before { expect(arguments).to receive(:exec).with(*%W(heroku some command -r some-remote)).and_return(exec_return) }
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
