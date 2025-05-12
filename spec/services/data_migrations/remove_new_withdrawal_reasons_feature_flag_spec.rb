require 'rails_helper'

RSpec.describe DataMigrations::RemoveNewWithdrawalReasonsFeatureFlag do
  context 'when the feature flag exist' do
    it 'removes the relevant feature flags' do
      create(:feature, name: 'new_candidate_withdrawal_reasons')
      create(:feature, name: 'some_other_feature_flag')

      expect { described_class.new.change }.to change { Feature.count }.by(-1)
      expect(Feature.where(name: 'new_candidate_withdrawal_reasons')).to be_none
      expect(Feature.where(name: 'some_other_feature_flag')).to be_any
    end
  end

  context 'when the feature flags have already been dropped' do
    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end
