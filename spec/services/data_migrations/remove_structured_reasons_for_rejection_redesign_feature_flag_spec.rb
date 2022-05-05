require 'rails_helper'

RSpec.describe DataMigrations::RemoveStructuredReasonsForRejectionRedesignFeatureFlag do
  context 'when the feature flag exists' do
    it 'removes the feature flag' do
      create(:feature, name: 'structured_reasons_for_rejection_redesign')
      expect { described_class.new.change }.to change { Feature.count }.by(-1)
      expect(Feature.where(name: 'structured_reasons_for_rejection_redesign')).to be_blank
    end
  end

  context 'when the feature flag has already been dropped' do
    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end
