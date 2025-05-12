require 'rails_helper'

RSpec.describe DataMigrations::RemoveUnlockApplicationForEditingFeatureFlag do
  context 'when the feature flag exists' do
    it 'removes the feature flag' do
      create(:feature, name: 'unlock_application_for_editing')
      expect { described_class.new.change }.to change { Feature.count }.by(-1)
      expect(Feature.where(name: 'unlock_application_for_editing')).to be_blank
    end
  end

  context 'when the feature flag has already been dropped' do
    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end
