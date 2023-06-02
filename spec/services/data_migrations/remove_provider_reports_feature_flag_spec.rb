require 'rails_helper'

RSpec.describe DataMigrations::RemoveProviderReportsFeatureFlag do
  context 'when the feature flag exists' do
    before do
      create(:feature, name: 'provider_reports')
      create(:feature, name: 'foo')
    end

    it 'removes the relevant feature flag' do
      expect { described_class.new.change }.to change { Feature.count }.by(-1)
      expect(Feature.where(name: 'provider_reports')).to be_none
      expect(Feature.where(name: 'foo')).to be_present
    end
  end

  context 'when the feature flags have already been dropped' do
    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end
