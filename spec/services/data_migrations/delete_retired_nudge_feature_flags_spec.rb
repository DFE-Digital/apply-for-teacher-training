require 'rails_helper'

RSpec.describe DataMigrations::DeleteRetiredNudgeFeatureFlags do
  context 'when the feature flags exist' do
    it 'removes both feature flags' do
      create(:feature, name: 'candidate_nudge_emails')
      create(:feature, name: 'candidate_nudge_course_choice_and_personal_statement')

      expect { described_class.new.change }.to change { Feature.count }.by(-2)
      expect(Feature.where(name: 'candidate_nudge_emails')).to be_blank
      expect(Feature.where(name: 'candidate_nudge_course_choice_and_personal_statement')).to be_blank
    end
  end

  context 'when the feature flags have already been dropped' do
    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end
