require 'rails_helper'

RSpec.describe 'Immigration Status', time: CycleTimetableHelper.mid_cycle do
  subject(:application_choice_submission) do
    CandidateInterface::ContinuousApplications::ApplicationChoiceSubmission.new(application_choice:)
  end

  let(:routes) { Rails.application.routes.url_helpers }
  let(:view) do
    Class.new do
      include ActionView::Helpers::UrlHelper
      include GovukLinkHelper
    end.new
  end
  let(:course) { create(:course, :with_course_options, :open_on_apply, level: 'secondary') }
  let(:application_form) { create(:application_form, :completed) }
  let(:application_choice) { create(:application_choice, :unsubmitted, course:, application_form:) }
  let(:link_to_find) { view.govuk_link_to('Find a course that has visa sponsorship', routes.find_url, target: '_blank', rel: 'nofollow') }

  context 'when candidate is uk or irish national' do
    it 'is valid' do
      expect(application_choice_submission).to be_valid
    end
  end

  context 'when candidate is American without right to work but course is salary and sponsored' do
    let(:application_form) { create(:application_form, :completed, first_nationality: 'American', right_to_work_or_study: 'no', efl_completed: true) }
    let(:course) { create(:course, :with_course_options, :open_on_apply, funding_type: 'fee', can_sponsor_student_visa: true, level: 'secondary') }

    it 'is valid' do
      expect(application_choice_submission).to be_valid
    end
  end

  context 'when candidate nationality is not British or Irish' do
    let(:application_form) { create(:application_form, :completed, first_nationality: 'American', right_to_work_or_study: 'no', efl_completed: true) }

    it 'adds error to application choice' do
      expect(application_choice_submission).not_to be_valid
      expect(application_choice_submission.errors[:application_choice]).to include(
        t('activemodel.errors.models.candidate_interface/continuous_applications/application_choice_submission.attributes.application_choice.immigration_status', link_to_find:),
      )
    end
  end

  context 'when candidate has right to work but course does not sponsor visa' do
    let(:application_form) { create(:application_form, :completed, first_nationality: 'American', right_to_work_or_study: 'no', efl_completed: true) }
    let(:course) { create(:course, :with_course_options, :open_on_apply, funding_type: 'fee', can_sponsor_student_visa: false, level: 'secondary') }

    it 'adds error to application choice' do
      expect(application_choice_submission).not_to be_valid
      expect(application_choice_submission.errors[:application_choice]).to include(
        t('activemodel.errors.models.candidate_interface/continuous_applications/application_choice_submission.attributes.application_choice.immigration_status', link_to_find:),
      )
    end
  end
end
