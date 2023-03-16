require 'rails_helper'

RSpec.describe Adviser::Constants do
  describe '#fetch' do
    it 'returns the constant value' do
      expect(described_class.fetch('teaching_subjects', 'primary')).to eq('b02655a1-2afa-e811-a981-000d3a276620')
      expect(described_class.fetch('uk_degree_grades')).to include('First-class honours' => 222_750_001)
    end

    it 'supports symbol keys' do
      expect(described_class.fetch(:teaching_subjects, 'primary')).to eq('b02655a1-2afa-e811-a981-000d3a276620')
    end

    it 'supports boolean keys' do
      expect(described_class.fetch(:gcse, true)).to eq(222_750_000)
      expect(described_class.fetch(:gcse, false)).to eq(222_750_001)
    end

    it 'returns nil if the key is not found' do
      expect(described_class.fetch(:unknown, :key)).to be_nil
    end

    it 'caches the YAML file' do
      allow(YAML).to receive(:load_file).with(described_class::CONSTANTS_PATH).and_call_original

      described_class.fetch('teaching_subjects')
      described_class.fetch('uk_degree_grades')

      expect(YAML).to have_received(:load_file).at_most(:once)
    end
  end
end
