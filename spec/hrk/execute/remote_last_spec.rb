require "spec_helper"

RSpec.describe Hrk::Execute::RemoteLast do
  describe "#call" do
    let(:next_callee) { double }

    subject(:remote_last) { Hrk::Execute::RemoteLast.new next_callee }

    before { allow(next_callee).to receive(:call) }

    context "normal cases" do
      def self.receiving args, it_should_pass_on: []
        context "receiving #{args.join " "}" do
          subject!(:result) { remote_last.call(*args) }

          it { expect(next_callee).to have_received(:call).with(*it_should_pass_on) }
        end
      end

      receiving %w(run console -r demo),
        it_should_pass_on: %w(run console -r demo)
      receiving %w(logs -t -a some-app-prod),
        it_should_pass_on: %w(logs -t -a some-app-prod)
      receiving %w(-r test run rake db:migrate),
        it_should_pass_on: %w(run rake db:migrate -r test)
      receiving %w(-a another-app-demo config),
        it_should_pass_on: %w(config -a another-app-demo)
      receiving %w(run -r testing rake db:migrate),
        it_should_pass_on: %w(run rake db:migrate -r testing)
      receiving %w(config:set -a the-main-app whatever="some_value"),
        it_should_pass_on: %w(config:set whatever="some_value" -a the-main-app)
      receiving %w(rake db:rollback),
        it_should_pass_on: %w(rake db:rollback)
      receiving %w(run console -a),
        it_should_pass_on: %w(run console -a)
      receiving %w(logs -t -r),
        it_should_pass_on: %w(logs -t -r)
    end

    context "edge cases" do
      def self.receiving args, it_should_raise: ArgumentError
        context "receiving #{args.join " "}" do
          subject(:the_command) { -> { remote_last.call(*args) } }

          it { expect(&the_command).to raise_error it_should_raise }

          context "the next callee" do
            before { the_command.call rescue nil }

            it { expect(next_callee).not_to have_received(:call) }
          end
        end
      end

      receiving %w(-r test run console -r demo),             it_should_raise: ArgumentError
      receiving %w(rake -a my-way db:migrate -a my-way-tmp), it_should_raise: ArgumentError
      receiving %w(-a super-app -r staging rake db:migrate), it_should_raise: ArgumentError
    end
  end
end
