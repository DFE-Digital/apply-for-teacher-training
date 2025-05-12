require 'rails_helper'

RSpec.describe DataMigrations::RemoveOneLoginPreReleaseBannersFeatureFlag do
  context 'when the feature flag exist' do
    it 'removes the relevant feature flags' do
      create(:feature, name: 'one_login_pre_release_banners')
      create(:feature, name: 'some_other_feature_flag')

      expect { described_class.new.change }.to change { Feature.count }.by(-1)
      expect(Feature.where(name: 'one_login_pre_release_banners')).to be_none
      expect(Feature.where(name: 'some_other_feature_flag')).to be_any
    end
  end

  context 'when the feature flags have already been dropped' do
    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end
