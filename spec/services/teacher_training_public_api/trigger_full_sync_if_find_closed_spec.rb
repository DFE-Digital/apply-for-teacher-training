require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::TriggerFullSyncIfFindClosed do
  before { allow(TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker).to receive(:perform_async) }

  context 'when find closed within the last day' do
    before { allow(CycleTimetable).to receive(:find_closes).and_return(5.minutes.ago) }

    it 'triggers a full sync for the next year ignoring update errors' do
      described_class.call
      expect(TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker).to have_received(:perform_async).with(false, RecruitmentCycle.next_year, true)
    end
  end

  context 'when find is yet to close' do
    before { allow(CycleTimetable).to receive(:find_closes).and_return(2.hours.from_now) }

    it 'does not trigger a sync' do
      described_class.call
      expect(TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker).not_to have_received(:perform_async)
    end
  end

  context 'when find closed over a day ago' do
    before { allow(CycleTimetable).to receive(:find_closes).and_return((1.day + 1.hour).ago) }

    it 'does not trigger a sync' do
      described_class.call
      expect(TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker).not_to have_received(:perform_async)
    end
  end
end
