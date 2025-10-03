require 'rails_helper'

RSpec.describe DataMigrations::RemoveCandidatePreferencesFeatureFlag do
  context 'when the feature flag exist' do
    it 'removes candidate_preference flag' do
      create(:feature, name: 'candidate_preferences')

      expect { described_class.new.change }.to change { Feature.count }.by(-1)
      expect(Feature.where(name: 'candidate_preferences')).to be_blank
    end
  end

  context 'when the feature flags have already been dropped' do
    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end
