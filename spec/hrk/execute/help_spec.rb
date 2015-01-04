require 'spec_helper'

RSpec.describe Hrk::Execute::Help do
  describe '#call' do
    subject(:help) { Hrk::Execute::Help.new }

    describe 'with the right arguments' do
      before { expect(help).to receive :display }

      it { expect(help.call).to eq true }
      it { expect(help.call('h')).to eq true }
      it { expect(help.call('-h')).to eq true }
      it { expect(help.call('help')).to eq true }
      it { expect(help.call('--help')).to eq true }
    end

    describe 'with wrong arguments' do
      [
        %w(run rake db:migrate),
        %w(helpe),
        %w(ahelp)
      ].each do |args|
        before { allow(help).to receive(:fallback).with(*args).and_return :fallouts }

        it { expect(help.call(*args)).to eq :fallouts}
      end
    end
  end

  describe '#display' do
    subject(:help) { Hrk::Execute::Help.new }

    before { allow(help).to receive :puts }
    before { help.display }

    it { expect(help).to have_received(:puts).at_least(1).times }
  end

  describe '#fallback' do
    describe 'without a fallback command' do
      subject(:help) { Hrk::Execute::Help.new }

      it { expect { help.fallback(*%w(whatever arguments it received)) }.to raise_error ArgumentError }
    end

    describe 'with a fallback command' do
      let(:fallback) { double }
      before { allow(fallback).to receive :call }

      subject(:help) { Hrk::Execute::Help.new fallback }

      before { expect(fallback).to receive(:call).with(*%w(whatever arguments it received)).and_return(:some_result) }

      it { expect(help.fallback(*%w(whatever arguments it received))).to eq :some_result }
    end
  end
end
