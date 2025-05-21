require 'rails_helper'

RSpec.describe DataMigrations::RemoveVisaSponsorshipDeadlineFeatureFlag do
  context 'when the feature flag exists' do
    it 'removes the feature flag' do
      create(:feature, name: 'early_application_deadlines_for_candidates_with_visa_sponsorship')
      expect { described_class.new.change }.to change { Feature.count }.by(-1)
      expect(Feature.where(name: 'show_support_find_a_candidate')).to be_blank
    end
  end

  context 'when the feature flag has already been dropped' do
    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end
