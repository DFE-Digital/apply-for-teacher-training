require 'rails_helper'

RSpec.describe InverseHash do
  before do
    stub_const('Klass', Class.new do
      using InverseHash

      def config(hsh)
        hsh.inverse
      end
    end)
  end

  subject(:run) { Klass.new.config(arg) }

  context 'when the hash is simple' do
    let(:arg) { { a: 1, b: 2 } }

    it { is_expected.to eq({ 1 => :a, 2 => :b }) }
  end

  context 'when the hash value is an array' do
    let(:arg) { { a: 1, b: [1, 2] } }

    it { is_expected.to eq({ 1 => %i[a b], 2 => [:b] }) }
  end

  context 'when the hash value is an hash' do
    let(:arg) { { a: 1, b: { c: 2 } } }

    it { expect { run }.to raise_error(StandardError, 'UninversableHashError: Cannot inverse a nested hash') }
  end
end
