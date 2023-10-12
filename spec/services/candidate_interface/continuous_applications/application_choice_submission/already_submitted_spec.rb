require 'rails_helper'

RSpec.describe 'Already Submitted application', time: CycleTimetableHelper.mid_cycle do
  subject(:application_choice_submission) do
    CandidateInterface::ContinuousApplications::ApplicationChoiceSubmission.new(application_choice:)
  end

  let(:course) { create(:course, :open_on_apply) }
  let(:application_form) { create(:application_form, :completed) }
  let(:application_choice) { create(:application_choice, :unsubmitted, application_form:, course:) }

  context 'valid' do
    it 'is valid' do
      expect(application_choice_submission).to be_valid
    end
  end

  context 'only science gcse section incomplete' do
    let(:course) { create(:course, :open_on_apply) }
    let(:course_option) { create(:course_option, course:) }
    let(:application_form) { create(:application_form, :completed, science_gcse_completed: false) }
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision, course_option:, application_form:) }

    it 'adds error to application choice' do
      expect(application_choice_submission).not_to be_valid
      expect(application_choice_submission.errors[:application_choice]).to include(message)
    end
  end

  def message
    t('activemodel.errors.models.candidate_interface/continuous_applications/application_choice_submission.attributes.application_choice.already_submitted')
  end
end
