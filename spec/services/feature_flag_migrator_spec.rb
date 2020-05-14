require 'rails_helper'

RSpec.describe FeatureFlagMigrator do
  describe '#call' do
    before do
      Feature.destroy_all
    end

    it 'creates required records in `features` table' do
      rollout = Rollout.new(Redis.current)
      FeatureFlag::FEATURES.each_key do |feature_name|
        rollout.send(feature_name == 'pilot_open' ? :activate : :deactivate, feature_name)
      end

      FeatureFlagMigrator.new.call
      expect(Feature.count).to eq FeatureFlag::FEATURES.count
      expect(Feature.where(active: true).pluck(:name)).to eq %w[pilot_open]
    end
  end
end
