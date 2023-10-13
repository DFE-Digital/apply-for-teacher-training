require 'rails_helper'

RSpec.describe 'Incomplete primary course form details', time: CycleTimetableHelper.mid_cycle do
  subject(:application_choice_submission) do
    CandidateInterface::ContinuousApplications::ApplicationChoiceSubmission.new(application_choice:)
  end

  let(:view) do
    Class.new do
      include ActionView::Helpers::UrlHelper
      include GovukLinkHelper
    end.new
  end
  let(:course) { create(:course, :open_on_apply, :with_course_options) }
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
    let(:application_choice) { create(:application_choice, :unsubmitted, course_option:, application_form:) }

    it 'adds error to application choice' do
      expect(application_choice_submission).not_to be_valid
      expect(application_choice_submission.errors[:application_choice]).to include(message)
    end
  end

  def message
    link_to_science = view.govuk_link_to('Add your science GCSE grade (or equivalent)', Rails.application.routes.url_helpers.candidate_interface_gcse_details_new_type_path('science'))

    t('activemodel.errors.models.candidate_interface/continuous_applications/application_choice_submission.attributes.application_choice.incomplete_primary_course_details', link_to_science:)
  end
end
