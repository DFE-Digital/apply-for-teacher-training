require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::FullSyncAllProvidersAndCoursesWorker do
  describe '#perform' do
    it 'calls the SyncSubjects service' do
      allow(TeacherTrainingPublicAPI::SyncAllProvidersAndCourses).to receive(:call).with(incremental_sync: false)

      sync_subjects_service = instance_double(TeacherTrainingPublicAPI::SyncSubjects, perform: nil)
      allow(TeacherTrainingPublicAPI::SyncSubjects).to receive(:new).and_return(sync_subjects_service)

      described_class.new.perform

      expect(TeacherTrainingPublicAPI::SyncAllProvidersAndCourses).to have_received(:call).with(incremental_sync: false)
      expect(sync_subjects_service).to have_received(:perform)
    end
  end
end
