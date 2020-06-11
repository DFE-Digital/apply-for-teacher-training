require 'rails_helper'

RSpec.describe SendCourseFullNotificationsWorker do
  describe '#perform', sidekiq: true do
    context 'with feature flag inactive' do
      it 'sends a Slack notification but no email' do
        application_choice = create :application_choice
        application_choice.course_option.update(vacancy_status: :no_vacancies)
        allow(SlackNotificationWorker).to receive(:perform_async)
        allow(CandidateMailer).to receive(:course_unavailable_notification)
        allow(GetApplicationChoicesWithNewlyUnavailableCourses).to receive(:call).and_return([application_choice])
        SendCourseFullNotificationsWorker.new.perform
        expect(CandidateMailer).not_to have_received(:course_unavailable_notification)
        expect(ChaserSent.where(chased: application_choice, chaser_type: :course_unavailable_notification)).not_to be_present
        expect(ChaserSent.where(chased: application_choice, chaser_type: :course_unavailable_slack_notification)).to be_present
        expect(SlackNotificationWorker).to have_received(:perform_async).with(
          "#{application_choice.course.name_and_code} at #{application_choice.course.provider.name} became full while #{application_choice.application_form.first_name} was awaiting references",
          Rails.application.routes.url_helpers.support_interface_application_form_url(application_choice.application_form),
        )
      end

      it 'does not send repeated Slack notification if ChaserSent record is already present' do
        application_choice = create :application_choice
        application_choice.course_option.update(vacancy_status: :no_vacancies)
        allow(SlackNotificationWorker).to receive(:perform_async)
        allow(CandidateMailer).to receive(:course_unavailable_notification)
        allow(GetApplicationChoicesWithNewlyUnavailableCourses).to receive(:call).and_return([application_choice])
        ChaserSent.create!(
          chased: application_choice,
          chaser_type: :course_unavailable_slack_notification,
        )
        SendCourseFullNotificationsWorker.new.perform
        expect(CandidateMailer).not_to have_received(:course_unavailable_notification)
        expect(ChaserSent.where(chased: application_choice, chaser_type: :course_unavailable_notification)).not_to be_present
        expect(SlackNotificationWorker).not_to have_received(:perform_async)
      end
    end

    context 'with feature flag active' do
      before do
        FeatureFlag.activate(:unavailable_course_notifications)
      end

      it 'sends emails to candidates that applied to a course that is now withdrawn' do
        application_choice = create :application_choice
        application_choice.course.update(withdrawn: true)
        allow(CandidateMailer).to receive(:course_unavailable_notification).and_call_original
        allow(GetApplicationChoicesWithNewlyUnavailableCourses).to receive(:call).and_return([application_choice])
        SendCourseFullNotificationsWorker.new.perform
        expect(CandidateMailer).to have_received(:course_unavailable_notification).with(application_choice, :course_withdrawn).at_least(:once)
        expect(ChaserSent.where(chased: application_choice, chaser_type: :course_unavailable_notification)).to be_present
        expect(ChaserSent.where(chased: application_choice, chaser_type: :course_unavailable_slack_notification)).to be_present
      end

      it 'sends emails to candidates that applied to a course that is now full' do
        application_choice = create :application_choice
        application_choice.course_option.update(vacancy_status: :no_vacancies)
        allow(CandidateMailer).to receive(:course_unavailable_notification).and_call_original
        allow(GetApplicationChoicesWithNewlyUnavailableCourses).to receive(:call).and_return([application_choice])
        SendCourseFullNotificationsWorker.new.perform
        expect(CandidateMailer).to have_received(:course_unavailable_notification).with(application_choice, :course_full).at_least(:once)
        expect(ChaserSent.where(chased: application_choice, chaser_type: :course_unavailable_notification)).to be_present
        expect(ChaserSent.where(chased: application_choice, chaser_type: :course_unavailable_slack_notification)).to be_present
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
        expect(ChaserSent.where(chased: application_choice, chaser_type: :course_unavailable_slack_notification)).to be_present
      end

      it 'sends emails to candidates that applied to a course that is now full for the selected study mode' do
        application_choice = create :application_choice
        application_choice.course_option.update(vacancy_status: :no_vacancies, study_mode: :full_time)
        create :course_option, course: application_choice.course, site: application_choice.course_option.site, study_mode: :part_time
        allow(CandidateMailer).to receive(:course_unavailable_notification).and_call_original
        allow(GetApplicationChoicesWithNewlyUnavailableCourses).to receive(:call).and_return([application_choice])
        SendCourseFullNotificationsWorker.new.perform
        expect(CandidateMailer).to have_received(:course_unavailable_notification).with(application_choice, :study_mode_full).at_least(:once)
        expect(ChaserSent.where(chased: application_choice, chaser_type: :course_unavailable_notification)).to be_present
        expect(ChaserSent.where(chased: application_choice, chaser_type: :course_unavailable_slack_notification)).to be_present
      end
    end
  end
end
