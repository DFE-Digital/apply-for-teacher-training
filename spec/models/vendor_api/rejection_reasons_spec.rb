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
        { id: 'qualifications', label: 'Qualifications', details: { id: 'qualifications_details', label: 'Details' } },
      )
    end
  end

  describe 'new' do
    it 'populates selected reasons from codes' do
      instance = described_class.new([
        { code: 'R01', details: 'No relevant qualifications' },
        { code: 'R09', details: 'Some other stuff' },
      ])

      expect(instance.selected_reasons.first).to be_a(::RejectionReasons::Reason)
      expect(instance.selected_reasons.first.label).to eq('Qualifications')
      expect(instance.selected_reasons.first.details.text).to eq('No relevant qualifications')
      expect(instance.selected_reasons.last).to be_a(::RejectionReasons::Reason)
      expect(instance.selected_reasons.last.label).to eq('Other')
      expect(instance.selected_reasons.last.details.text).to eq('Some other stuff')
    end
  end
end
