require 'rails_helper'

RSpec.describe DataMigrations::RemoveAPIAndMonthlyStatisticsFeatureFlags do
  context 'when the feature flags exist' do
    it 'removes candidate_preference flag' do
      create(:feature, name: 'api_token_management')
      create(:feature, name: 'monthly_statistics_redirected')

      expect { described_class.new.change }.to change { Feature.count }.by(-2)
      expect(Feature.where(name: 'api_token_management')).to be_blank
      expect(Feature.where(name: 'monthly_statistics_redirected')).to be_blank
    end
  end

  context 'when the api feature flag have already been dropped' do
    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end
