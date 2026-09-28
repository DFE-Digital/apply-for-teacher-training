require 'rails_helper'

RSpec.describe DataMigrations::RemoveVisaExpiryFeatureFlag do
  context 'when the feature flag exists' do
    before do
      create(:feature, name: '2027_visa_expiry') if Feature.find_by(name: '2027_visa_expiry').blank?
      create(:feature, name: 'foo')
    end

    it 'removes the relevant feature flag' do
      expect { described_class.new.change }.to change { Feature.count }.by(-1)
      expect(Feature.where(name: '2027_visa_expiry')).to be_none
      expect(Feature.where(name: 'foo')).to be_present
    end
  end

  context 'when the feature flags have already been dropped' do
    before do
      Feature.find_by(name: '2027_visa_expiry')&.destroy if Feature.find_by(name: '2027_visa_expiry').present?
    end

    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end
