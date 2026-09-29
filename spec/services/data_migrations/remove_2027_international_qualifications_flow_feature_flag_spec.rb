require 'rails_helper'

RSpec.describe DataMigrations::Remove2027InternationalQualificationsFlowFeatureFlag do
  before do
    create(:feature, name: '2027_international_qualifications_flow') if Feature.find_by(name: '2027_international_qualifications_flow').blank?
    create(:feature, name: 'foo')
  end

  context 'when the feature flag exists' do
    it 'removes the relevant feature flag' do
      expect { described_class.new.change }.to change { Feature.count }.by(-1)
      expect(Feature.where(name: '2027_international_qualifications_flow')).to be_none
      expect(Feature.where(name: 'foo')).to be_present
    end
  end

  context 'when the feature flags have already been dropped' do
    before do
      Feature.find_by(name: '2027_international_qualifications_flow')&.destroy if Feature.find_by(name: '2027_international_qualifications_flow').present?
    end

    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end

