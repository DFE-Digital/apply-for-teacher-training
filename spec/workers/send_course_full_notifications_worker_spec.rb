require 'rails_helper'

RSpec.describe SendCourseFullNotificationsWorker do
  describe '#perform', sidekiq: true do
    it 'sends emails to candidates that applied to a course that is now full' do
      application_choice = create :application_choice
      application_choice.course_option.update(vacancy_status: :no_vacancies)
      allow(CandidateMailer).to receive(:course_unavailable_notification).and_call_original
      allow(GetApplicationChoicesWithNewlyUnavailableCourses).to receive(:call).and_return([application_choice])
      SendCourseFullNotificationsWorker.new.perform
      expect(CandidateMailer).to have_received(:course_unavailable_notification).with(application_choice, :course_full).at_least(:once)
    end

    it 'sends emails to candidates that applied to a course that is now full at the selected location' do
      pending 'need to implement the course_full template'
      application_choice = create :application_choice
      application_choice.course_option.update(vacancy_status: :no_vacancies)
      create :course_option, course: application_choice.course
      allow(CandidateMailer).to receive(:course_unavailable_notification).and_call_original
      allow(GetApplicationChoicesWithNewlyUnavailableCourses).to receive(:call).and_return([application_choice])
      SendCourseFullNotificationsWorker.new.perform
      expect(CandidateMailer).to have_received(:course_unavailable_notification).with(application_choice, :location_full).at_least(:once)
    end
  end
end
