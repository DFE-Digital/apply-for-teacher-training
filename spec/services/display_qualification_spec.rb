require 'rails_helper'

RSpec.describe DisplayQualification do
  context 'when qts' do
    let(:qualification) { 'qts' }

    it 'returns "QTS"' do
      expect(described_class.call(qualification: qualification)).to eq 'QTS'
    end
  end

  context 'when pgce' do
    let(:qualification) { 'pgce' }

    it 'returns "PGCE only (without QTS)"' do
      expect(described_class.call(qualification: qualification)).to eq 'PGCE only (without QTS)'
    end
  end

  context 'when pgde' do
    let(:qualification) { 'pgde' }

    it 'returns "PGDE only (without QTS"' do
      expect(described_class.call(qualification: qualification)).to eq 'PGDE only (without QTS)'
    end
  end

  context 'when pgce_with_qts' do
    let(:qualification) { 'pgce_with_qts' }

    it 'returns "PGCE with QTS"' do
      expect(described_class.call(qualification: qualification)).to eq 'PGCE with QTS'
    end
  end

  context 'when pgde_with_qts' do
    let(:qualification) { 'pgde_with_qts' }

    it 'returns "PGDE with QTS"' do
      expect(described_class.call(qualification: qualification)).to eq 'PGDE with QTS'
    end
  end
end
