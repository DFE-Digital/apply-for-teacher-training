require 'rails_helper'

RSpec.describe GetApplicationChoicesWithNewlyUnavailableCourses do
  include CourseOptionHelpers

  it 'only returns awaiting references application choices with a course that has no vacancies' do
    application_choice_without_vacancies = create(
      :awaiting_references_application_choice,
      course_option: create(:course_option, :no_vacancies),
    )
    create(
      :submitted_application_choice,
      course_option: create(:course_option, :no_vacancies),
    )
    create :awaiting_references_application_choice
    expect(described_class.call.map(&:id)).to eq([application_choice_without_vacancies.id])
  end

  it 'does not return application choices that have already received the notification email' do
    pending 'need to merge with migration to add the `course_unavailable_notification_sent_at` column'
    create(
      :awaiting_references_application_choice,
      course_option: create(:course_option, :no_vacancies),
      course_unavailable_notification_sent_at: 1.day.ago,
    )
    expect(described_class.call.map(&:id)).to eq([])
  end
end
