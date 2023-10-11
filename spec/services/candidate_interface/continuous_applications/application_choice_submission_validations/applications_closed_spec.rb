require 'rails_helper'

RSpec.describe 'Applications closed', time: CycleTimetableHelper.mid_cycle do
  subject(:application_choice_submission) do
    CandidateInterface::ContinuousApplications::ApplicationChoiceSubmission.new(application_choice:)
  end

  let(:course) { create(:course, :with_course_options, :open_on_apply, level: 'secondary') }
  let(:application_form) { create(:application_form, :completed) }
  let(:application_choice) { create(:application_choice, :unsubmitted, course:, application_form:) }

  context 'when apply is open and course is open for applications' do
    it 'is valid' do
      expect(application_choice_submission).to be_valid
    end
  end

  context 'when apply is open but course not open for applications' do
    it 'adds error to application choice' do
      application_choice.course.update(applications_open_from: 1.day.from_now)

      expect(application_choice_submission).not_to be_valid
      expect(application_choice_submission.errors[:application_choice]).to include(
        "This course is not yet open to applications. You’ll be able to submit your application on #{1.day.from_now.to_fs(:govuk_date)}.",
      )
    end
  end

  context 'when apply is closed and course open for applications same day' do
    it 'adds error to application choice', time: CycleTimetableHelper.after_find_opens do
      expect(application_choice_submission).not_to be_valid
      expect(application_choice_submission.errors[:application_choice]).to include(
        "This course is not yet open to applications. You’ll be able to submit your application on #{CycleTimetable.apply_opens.to_fs(:govuk_date)}.",
      )
    end
  end

  context 'when apply is open and course open for applications next day' do
    let(:course_opens_at) { 1.day.from_now }
    let(:course) { create(:course, :with_course_options, level: 'secondary', applications_open_from: course_opens_at) }

    it 'adds error to application choice' do
      expect(application_choice_submission).not_to be_valid
      expect(application_choice_submission.errors[:application_choice]).to include(
        "This course is not yet open to applications. You’ll be able to submit your application on #{course.applications_open_from.to_fs(:govuk_date)}.",
      )
    end
  end
end
