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
      expect(TeacherTrainingPublicAPI::SyncAllProvidersAndCourses).to have_received(:call).with(incremental_sync: true, recruitment_cycle_year: RecruitmentCycle.current_year, suppress_sync_update_errors: false)
    end

    it 'calls the SyncAllProvidersAndCourses service with the correct args for a full sync' do
      described_class.new.perform(false)
      expect(TeacherTrainingPublicAPI::SyncAllProvidersAndCourses).to have_received(:call).with(incremental_sync: false, recruitment_cycle_year: RecruitmentCycle.current_year, suppress_sync_update_errors: false)
    end

    context 'when the hosting environment is review' do
      around do |example|
        ClimateControl.modify(HOSTING_ENVIRONMENT_NAME: 'review') { example.run }
      end

      it 'does not call the SyncSubjects service' do
        described_class.new.perform
        expect(stubbed_sync_subjects_service).not_to have_received(:perform)
      end

      it 'does not call the SyncAllProvidersAndCourses' do
        described_class.new.perform
        expect(TeacherTrainingPublicAPI::SyncAllProvidersAndCourses).not_to have_received(:call)
      end
    end
  end
end
