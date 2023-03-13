require 'rails_helper'

RSpec.describe VendorAPI::RejectionReasons do
  describe '#find' do
    it 'raises on invalid code' do
      expect {
        described_class.new.find('hohoho')
      }.to raise_error(VendorAPI::RejectionReasonCodeNotFound)
    end

    it 'returns the hash entry for code' do
      expect(described_class.new.find('R01')).to eq(
        {
          id: 'qualifications',
          label: 'Qualifications',
          details: {
            id: 'qualifications_details',
            label: 'Details',
            text: "You did not have the required or relevant qualifications, or we could not find record of your qualifications.\n",
          },
        },
      )
    end
  end

  describe 'initialize' do
    it 'populates selected reasons from codes' do
      instance = described_class.new([
        { code: 'R01', details: 'No relevant qualifications' },
        { code: 'R08', details: 'Course is full' },
      ])

      expect(instance.selected_reasons.first).to be_a(RejectionReasons::Reason)
      expect(instance.selected_reasons.first.label).to eq('Qualifications')
      expect(instance.selected_reasons.first.details.text).to eq('No relevant qualifications')
      expect(instance.selected_reasons.last).to be_a(RejectionReasons::Reason)
      expect(instance.selected_reasons.last.label).to eq('Course full')
      expect(instance.selected_reasons.last.details.text).to eq('Course is full')
    end
  end

  describe '.reference_data' do
    it 'returns an array of reference-data hashes for rejection reasons' do
      expect(described_class.reference_data.map { |d| d[:code] }).to eq(described_class::CODES.keys)
      expect(described_class.reference_data.map { |d| d[:label] }).to eq(described_class::CODES.values.map { |h| h[:label] })
      expect(described_class.reference_data.map { |d| d[:default_details] }).to eq(
        described_class::CODES.values.map { |h| h.dig(:details, :text) },
      )
    end
  end
end
