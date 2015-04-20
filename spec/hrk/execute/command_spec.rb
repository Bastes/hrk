require "spec_helper"

RSpec.describe Hrk::Execute::Command do
  describe "#call" do
    subject(:command) { Hrk::Execute::Command.new }

    let(:heroku) { double("Hrk::Heroku") }
    before { allow(heroku).to receive(:call) }
    before { allow(Hrk::Heroku).to receive(:new).and_return(heroku) }

    before { allow(command.env).to receive(:remote=) }

    context "no remote was previously memorized" do
      before { allow(command.env).to receive(:remote?).and_return(nil) }

      describe "standard case (a remote, a command)" do
        let(:remote) { "remote-#{rand(1..9)}" }
        let(:args)   { %w(whatever that:may -b) }

        %w(-a -r).each do |opt|
          context "using #{opt}" do
            [true, false].each do |result|
              context "when the command returns #{result}" do
                before { allow(heroku).to receive(:call).and_return(result) }

                it { expect(command.call(*args, opt, remote)).to eq result }
              end
            end

            describe "interactions" do
              before { command.call(*args, opt, remote) }

              it { expect(Hrk::Heroku).to have_received(:new).with(opt, remote) }
              it { expect(heroku).to have_received(:call).with(*%w{whatever that:may -b}) }
              it { expect(command.env).to have_received(:remote=).with([opt, remote]) }
            end
          end
        end
      end

      describe "edge cases" do
        describe "a remote, nocommand" do
          let(:remote) { "remote-#{rand(1..9)}" }

          %w(-a -r).each do |opt|
            context "using #{opt}" do
              [true, false].each do |result|
                context "when the command returns #{result}" do
                  before { allow(heroku).to receive(:call).and_return(result) }

                  it { expect(command.call(opt, remote)).to eq result }
                end
              end

              describe "interactions" do
                before { command.call(opt, remote) }

                it { expect(Hrk::Heroku).to have_received(:new).with(opt, remote) }
                it { expect(heroku).to have_received(:call).with no_args }
                it { expect(command.env).to have_received(:remote=).with([opt, remote]) }
              end
            end
          end
        end

        describe "no remote, improper remote..." do
          let(:other_args) { %W(something-#{rand(1..9)} -o r --another) }

          before { expect(heroku).not_to receive(:call) }
          before { expect(command.env).not_to receive(:remote=) }

          it { expect { command.call }.to raise_error ArgumentError }
          it { expect { command.call(*other_args) }.to raise_error ArgumentError }
          it { expect { command.call(*other_args, "-r") }.to raise_error ArgumentError }
          it { expect { command.call(*other_args, "-a") }.to raise_error ArgumentError }
          it { expect { command.call(*other_args, *%w(-r demo -r prod)) }.to raise_error ArgumentError }
          it { expect { command.call(*other_args, *%w(-a app -a other-app)) }.to raise_error ArgumentError }
          it { expect { command.call(*other_args, *%w(-r staging -a server)) }.to raise_error ArgumentError }
          it { expect { command.call(*other_args, *%w(-a machine -r dennis)) }.to raise_error ArgumentError }
        end
      end
    end
  end
end
