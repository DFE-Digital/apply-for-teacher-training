require 'rails_helper'

RSpec.describe 'Incomplete details including primary course form details', time: CycleTimetableHelper.mid_cycle do
  subject(:application_choice_submission) do
    CandidateInterface::ContinuousApplications::ApplicationChoiceSubmission.new(application_choice:)
  end

  context 'missing details'
  context 'valid, then add primary choice, invalid, add science GCSE, valid'

  let(:view) do
    Class.new do
      include ActionView::Helpers::UrlHelper
      include GovukLinkHelper
    end.new
  end
  let(:course) { create(:course, :open_on_apply, :primary) }
  let(:course_option) { create(:course_option, :open_on_apply, course:) }
  let(:application_form) { create(:application_form, :completed) }
  let(:application_choice) { create(:application_choice, :unsubmitted, application_form:, course_option:) }

  context 'valid' do
    it 'is valid' do
      expect(application_choice_submission).to be_valid
    end
  end

  context 'science gcse section incomplete and other details incomplete' do
    let(:application_form) { create(:application_form, :completed, degrees_completed: false, science_gcse_completed: false) }
    let(:application_choice) { create(:application_choice, :unsubmitted, course_option:, application_form:) }

    context 'when primary courses' do
      it 'adds error to application choice' do
        expect(application_choice_submission).not_to be_valid
        expect(application_choice_submission.errors[:application_choice]).to include(message)
      end
    end

    context 'when secondary courses' do
      let(:course) { create(:course, :open_on_apply, :secondary) }

      it 'does not add an error to incomplete science GCSE' do
        application_choice_submission.valid?

        expect(application_choice_submission.errors.map(&:type)).to eq([:incomplete_details])
      end
    end
  end

  def message
    link_to_details = view.govuk_link_to('Add your science GCSE grade (or equivalent)', Rails.application.routes.url_helpers.candidate_interface_continuous_applications_details_path)
    t('activemodel.errors.models.candidate_interface/continuous_applications/application_choice_submission.attributes.application_choice.incomplete_details_including_primary_course_details', link_to_details:)
  end
end
