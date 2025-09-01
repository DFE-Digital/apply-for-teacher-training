require 'rails_helper'

RSpec.describe EndOfCycle::NextYearFullSync do
  describe '#perform' do
    before do
      allow(TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker)
        .to receive(:perform_async).with(false, next_year)
    end

    context 'after find has closed' do
      it 'does not enqueue the job' do
        travel_temporarily_to(1.second.after(current_timetable.find_closes_at)) do
          described_class.new.perform

          expect(TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker)
            .not_to have_received(:perform_async)
        end
      end
    end

    context 'before full sync start start time' do
      it 'does not enqueue the job' do
        start_syncing_after = 8.weeks.before(current_timetable.apply_deadline_at).change(hour: 0o0, min: 4)
        start_syncing_after = start_syncing_after.next_occurring(:friday) unless start_syncing_after.friday?

        travel_temporarily_to(1.minute.before(start_syncing_after)) do
          described_class.new.perform

          expect(TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker)
            .not_to have_received(:perform_async)
        end
      end
    end

    context 'after the full sync start time' do
      it 'enqueues the job with the expected arguments' do
        start_syncing_after = 8.weeks.before(current_timetable.apply_deadline_at).change(hour: 0o0, min: 4)
        start_syncing_after = start_syncing_after.next_occurring(:friday) unless start_syncing_after.friday?

        travel_temporarily_to(1.minute.after(start_syncing_after)) do
          described_class.new.perform

          expect(TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker)
            .to have_received(:perform_async).with(false, next_year)
        end
      end
    end
  end
end
