require 'rails_helper'

RSpec.describe DataMigrations::RemoveSummerRecruitmentBannerFeatureFlag do
  context 'when the feature flag exists' do
    it 'removes the feature flag' do
      create(:feature, name: 'summer_recruitment_banner')
      expect { described_class.new.change }
        .to change { Feature.where(name: 'summer_recruitment_banner').any? }
        .from(true)
        .to(false)
    end
  end

  context 'when the feature flag has already been dropped' do
    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end
