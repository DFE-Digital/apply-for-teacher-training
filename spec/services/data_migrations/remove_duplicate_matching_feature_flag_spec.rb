require 'rails_helper'

RSpec.describe DataMigrations::RemoveDuplicateMatchingFeatureFlag do
  context 'when the feature flag exists' do
    before do
      create(:feature, name: 'duplicate_matching')
    end

    it 'removes the feature flag' do
      expect { described_class.new.change }.to change { Feature.count }.by(-1)
      expect(Feature.where(name: 'duplicate_matching')).to be_blank
    end
  end

  context 'when the feature flag has already been dropped' do
    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end
