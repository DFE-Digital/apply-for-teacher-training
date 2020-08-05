require 'rails_helper'

RSpec.describe SendCourseFullNotificationsWorker do
  describe '#perform', sidekiq: true do
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
