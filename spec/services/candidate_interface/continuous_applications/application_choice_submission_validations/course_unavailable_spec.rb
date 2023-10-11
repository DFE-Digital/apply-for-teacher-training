require 'rails_helper'

RSpec.describe 'Course is not available', time: CycleTimetableHelper.mid_cycle do
  subject(:application_choice_submission) do
    CandidateInterface::ContinuousApplications::ApplicationChoiceSubmission.new(application_choice:)
  end

  let(:view) do
    Class.new do
      include ActionView::Helpers::UrlHelper
      include GovukLinkHelper
    end.new
  end
  let(:course) { build(:course, :open_on_apply, course_options: []) }
  let(:course_option) { create(:course_option, course: course) }
  let(:application_form) { create(:application_form, :completed) }
  let(:application_choice) { create(:application_choice, application_form:) }

  context 'all validations pass' do
    let(:course) { build(:course, :open_on_apply, :with_course_options) }

    it 'adds no errors to application choice submission' do
      expect(application_choice_submission).to be_valid
    end
  end

  context 'course is full' do
    let(:course_option) { create(:course_option, :no_vacancies, course: course) }
    let(:application_choice) { create(:application_choice, course_option: course_option, application_form:) }

    it 'adds error to application choice submission' do
      expect(application_choice_submission).not_to be_valid
      expect(application_choice_submission.errors[:application_choice]).to include(message(application_choice))
    end
  end

  context 'course not exposed in find' do
    let(:course) { build(:course, :open_on_apply, exposed_in_find: false, course_options: []) }
    let(:application_form) { create(:application_form, :minimum_info) }
    let(:application_choice) { create(:application_choice, course_option: course_option, application_form:) }

    it 'adds error to application choice submission' do
      expect(application_choice_submission).not_to be_valid
      expect(application_choice_submission.errors[:application_choice]).to include(message(application_choice))
    end
  end

  context 'course site not still valid' do
    let(:course_option) { create(:course_option, site_still_valid: false, course: course) }
    let(:application_form) { create(:application_form, :minimum_info) }
    let(:application_choice) { create(:application_choice, course_option: course_option, application_form:) }

    it 'adds error to application choice submission' do
      expect(application_choice_submission).not_to be_valid
      expect(application_choice_submission.errors[:application_choice]).to include(message(application_choice))
    end
  end

  def message(application_choice)
    <<~MSG.chomp
      You cannot submit this application as the course is no longer available.

      #{view.govuk_link_to('Remove this application', Rails.application.routes.url_helpers.candidate_interface_continuous_applications_confirm_destroy_course_choice_path(application_choice.id))} and search for other courses.
    MSG
  end
end
