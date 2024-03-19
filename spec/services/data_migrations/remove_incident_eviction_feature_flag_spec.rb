require 'rails_helper'

RSpec.describe DataMigrations::RemoveIncidentEvictionFeatureFlag do
  context 'when the feature flag exists' do
    it 'removes the relevant feature flag' do
      create(:feature, name: 'incident_eviction')
      create(:feature, name: 'foo')
      expect { described_class.new.change }.to change { Feature.count }.by(-1)
      expect(Feature.where(name: 'incident_eviction')).to be_none
      expect(Feature.where(name: 'foo')).to be_present
    end
  end

  context 'when the feature flag has already been dropped' do
    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end
