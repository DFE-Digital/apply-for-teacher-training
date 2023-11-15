require 'rails_helper'

RSpec.describe DataMigrations::RemoveRecruitWithPendingConditionsFeatureFlag do
  context 'when the feature flag exists' do
    before do
      create(:feature, name: 'recruit_with_pending_conditions')
    end

    it 'removes the relevant feature flags' do
      expect { described_class.new.change }.to change { Feature.count }.by(-1)
      expect(Feature.where(name: 'recruit_with_pending_conditions')).to be_empty
    end
  end

  context 'when the feature flag has already been dropped' do
    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end
