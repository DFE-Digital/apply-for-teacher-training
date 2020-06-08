require 'rails_helper'

RSpec.describe SendCourseFullNotificationsWorker do
  describe '#perform', sidekiq: true do
    it 'sends emails to candidates that applied to a course that is now full' do
      application_choice = build :application_choice
      allow(CandidateMailer).to receive(:course_unavailable_notification).and_return(double(deliver_later: true))
      allow(GetApplicationChoicesWithNewlyUnavailableCourses).to receive(:call).and_return([application_choice])
      SendCourseFullNotificationsWorker.new.perform
      expect(CandidateMailer).to have_received(:course_unavailable_notification)
    end
  end
end
