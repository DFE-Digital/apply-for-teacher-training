require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::TriggerFullSyncIfFindClosed do
  before { allow(TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker).to receive(:perform_async) }

  context 'when find closed within the last day' do
    it 'triggers a full sync for the next year ignoring update errors' do
      timetable = RecruitmentCycleTimetable.find_by(recruitment_cycle_year: 2024)

      travel_temporarily_to(timetable.find_closes_at + 5.minutes) do
        described_class.call
        expect(TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker).to have_received(:perform_async).with(false, 2025, true)
      end
    end
  end

  context 'when find is yet to close' do
    before do
      timetable = RecruitmentCycleTimetable.current_timetable
      TestSuiteTimeMachine.travel_permanently_to(2.hours.before(timetable.find_closes_at))
    end

    it 'does not trigger a sync' do
      described_class.call
      expect(TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker).not_to have_received(:perform_async)
    end
  end

  context 'when find closed over a day ago' do
    before do
      timetable = RecruitmentCycleTimetable.current_timetable
      TestSuiteTimeMachine.travel_permanently_to(timetable.find_closes_at + (1.day + 1.hour))
    end

    it 'does not trigger a sync' do
      described_class.call
      expect(TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker).not_to have_received(:perform_async)
    end
  end
end
