require 'rails_helper'

RSpec.describe SendCourseFullNotificationsWorker do
  describe '#perform', sidekiq: true do
    context 'with feature flag inactive' do
      it 'sends no emails' do
        application_choice = create :application_choice
        application_choice.course_option.update(vacancy_status: :no_vacancies)
        allow(CandidateMailer).to receive(:course_unavailable_notification)
        allow(GetApplicationChoicesWithNewlyUnavailableCourses).to receive(:call).and_return([application_choice])
        SendCourseFullNotificationsWorker.new.perform
        expect(CandidateMailer).not_to have_received(:course_unavailable_notification)
        expect(ChaserSent.where(chased: application_choice, chaser_type: :course_unavailable_notification)).not_to be_present
      end
    end

    context 'with feature flag active' do
      before do
        FeatureFlag.activate(:unavailable_course_notifications)
      end

      it 'sends emails to candidates that applied to a course that is now full' do
        application_choice = create :application_choice
        application_choice.course_option.update(vacancy_status: :no_vacancies)
        allow(CandidateMailer).to receive(:course_unavailable_notification).and_call_original
        allow(GetApplicationChoicesWithNewlyUnavailableCourses).to receive(:call).and_return([application_choice])
        SendCourseFullNotificationsWorker.new.perform
        expect(CandidateMailer).to have_received(:course_unavailable_notification).with(application_choice, :course_full).at_least(:once)
        expect(ChaserSent.where(chased: application_choice, chaser_type: :course_unavailable_notification)).to be_present
      end

      it 'sends emails to candidates that applied to a course that is now full at the selected location' do
        application_choice = create :application_choice
        application_choice.course_option.update(vacancy_status: :no_vacancies)
        create :course_option, course: application_choice.course
        allow(CandidateMailer).to receive(:course_unavailable_notification).and_call_original
        allow(GetApplicationChoicesWithNewlyUnavailableCourses).to receive(:call).and_return([application_choice])
        SendCourseFullNotificationsWorker.new.perform
        expect(CandidateMailer).to have_received(:course_unavailable_notification).with(application_choice, :location_full).at_least(:once)
        expect(ChaserSent.where(chased: application_choice, chaser_type: :course_unavailable_notification)).to be_present
      end
    end
  end
end
