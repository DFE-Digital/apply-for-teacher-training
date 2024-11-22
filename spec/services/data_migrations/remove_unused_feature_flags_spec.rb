require 'rails_helper'

RSpec.describe DataMigrations::RemoveUnusedFeatureFlags do
  context 'when the feature flags exist' do
    let(:feature_flags) do
      %i[
        deadline_notices
        lock_external_report_to_january_2022
        monthly_statistics_preview
        reference_nudges
        sample_applications_factory
        structured_reference_condition
        continuous_applications
        block_candidate_sign_in
      ]
    end

    before do
      feature_flags.each {   |name| create(:feature, name:) }

      create(:feature, name: 'some_other_feature_flag')
    end

    it 'removes the relevant feature flags' do
      expect { described_class.new.change }.to change { Feature.count }.by(feature_flags.length * -1)
      feature_flags.each { |name| expect(Feature.where(name:)).to be_none }

      expect(Feature.where(name: 'some_other_feature_flag')).to be_any
    end
  end

  context 'when the feature flags have already been dropped' do
    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end
