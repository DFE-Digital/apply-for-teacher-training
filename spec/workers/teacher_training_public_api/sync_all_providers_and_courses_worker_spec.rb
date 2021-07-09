require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker do
  describe '#perform' do
    let!(:stubbed_sync_subjects_service) do
      sync_subjects_service = instance_double(TeacherTrainingPublicAPI::SyncSubjects, perform: nil)
      allow(TeacherTrainingPublicAPI::SyncSubjects).to receive(:new).and_return(sync_subjects_service)
      sync_subjects_service
    end

    before do
      allow(TeacherTrainingPublicAPI::SyncAllProvidersAndCourses).to receive(:call)
    end

    it 'calls the SyncSubjects service' do
      described_class.new.perform
      expect(stubbed_sync_subjects_service).to have_received(:perform)
    end

    it 'calls the SyncAllProvidersAndCourses service with the correct args for an incremental sync' do
      described_class.new.perform
      expect(TeacherTrainingPublicAPI::SyncAllProvidersAndCourses).to have_received(:call).with(incremental_sync: true)
    end

    it 'calls the SyncAllProvidersAndCourses service with the correct args for a full sync' do
      described_class.new.perform(false)
      expect(TeacherTrainingPublicAPI::SyncAllProvidersAndCourses).to have_received(:call).with(incremental_sync: false)
    end

    context 'the sync_next_cycle feature flag is on' do
      before do
        FeatureFlag.activate(:sync_next_cycle)
      end

      it 'calls the SyncAllProvidersAndCourses service passing in the next cycle' do
        Timecop.travel(2021, 1, 1) do
          described_class.new.perform
        end

        expect(TeacherTrainingPublicAPI::SyncAllProvidersAndCourses).to have_received(:call).with(incremental_sync: true, recruitment_cycle_year: 2022)
      end
    end
  end
end
