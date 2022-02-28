require 'rails_helper'

RSpec.describe DataMigrations::DropApplyAgainWithThreeChoicesFeatureFlag do
  context 'when the feature flag exists' do
    it 'removes the feature flag' do
      create(:feature, name: 'apply_again_with_three_choices')
      expect { described_class.new.change }.to change { Feature.count }.by(-1)
      expect(Feature.where(name: 'apply_again_with_three_choices')).to be_blank
    end
  end

  context 'when the feature flag has already been dropped' do
    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end
