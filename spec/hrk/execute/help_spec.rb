require 'spec_helper'

RSpec.describe Hrk::Execute::Help do
  def self.args_for(arguments)
    Hrk::Heroku.new arguments
  end

  def args_for arguments
    self.class.args_for arguments
  end

  describe '#call' do
    subject(:help) { Hrk::Execute::Help.new the_next_callee_or_not }

    describe 'with the right arguments' do
      [true, false].each do |there_is_one|
        context "and #{there_is_one ? "a" : "no"} next callee" do
          if there_is_one
            let(:the_next_callee_or_not) { double(Hrk::Execute::Command) }
            before { allow(the_next_callee_or_not).to receive(:call).never }
          else
            let(:the_next_callee_or_not) { nil }
          end

          before { expect(help).to receive :puts }

          it { expect(help.call(args_for(%w()))).to eq true }
          it { expect(help.call(args_for(%w(h)))).to eq true }
          it { expect(help.call(args_for(%w(-h)))).to eq true }
          it { expect(help.call(args_for(%w(help)))).to eq true }
          it { expect(help.call(args_for(%w(--help)))).to eq true }
        end
      end
    end

    describe 'with other arguments' do
      [
        %w(run rake db:migrate),
        %w(helpe),
        %w(ahelp)
      ].map { |args| args_for args }.each do |args|
        context "and a next callee" do
          let(:the_next_callee_or_not) { double }
          before { allow(the_next_callee_or_not).to receive(:call).and_return :fallouts }

          it do
            expect(help.call(args)).to eq :fallouts
            expect(the_next_callee_or_not).to have_received(:call).with(args)
          end
        end

        context "and no next callee" do
          let(:the_next_callee_or_not) { nil }

          it { expect { help.call(args) }.to raise_error ArgumentError }
        end
      end
    end
  end
end
