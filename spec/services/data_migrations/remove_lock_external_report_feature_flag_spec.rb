require 'rails_helper'

RSpec.describe DataMigrations::RemoveLockExternalReportFeatureFlag do
  context 'when the feature flags exist' do
    before do
      create(:feature, name: 'lock_external_report_to_december_2021')
      create(:feature, name: 'some_other_feature_flag')
    end

    it 'removes the relevant feature flags' do
      expect { described_class.new.change }.to change { Feature.count }.by(-1)
      expect(Feature.where(name: 'lock_external_report_to_december_2021')).to be_none
      expect(Feature.where(name: 'some_other_feature_flag')).to be_any
    end
  end

  context 'when the feature flags have already been dropped' do
    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end
