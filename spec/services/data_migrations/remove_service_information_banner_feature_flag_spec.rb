require 'rails_helper'

RSpec.describe DataMigrations::RemoveServiceInformationBannerFeatureFlag do
  context 'when the feature flag exists' do
    before do
      create(:feature, name: 'service_information_banner')
      create(:feature, name: 'some_other_feature_flag')
    end

    it 'removes the relevant feature flag' do
      expect { described_class.new.change }.to change { Feature.count }.by(-1)
      expect(Feature.where(name: 'service_information_banner')).to be_none
      expect(Feature.where(name: 'some_other_feature_flag')).to be_any
    end
  end

  context 'when the feature flag has already been dropped' do
    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end
