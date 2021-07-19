require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::SyncAllProvidersAndCourses, sidekiq: true do
  include TeacherTrainingPublicAPIHelper

  describe '.call' do
    context 'paginates the correct number of pages' do
      before do
        allow(described_class).to receive(:sync_providers)
      end

      it 'calls sync providers 3 times' do
        stub_teacher_training_api_providers_with_multiple_pages
        described_class.call(incremental_sync: false)

        expect(described_class).to have_received(:sync_providers).exactly(3).times
      end
    end

    context 'when intremental sync is off' do
      before do
        allow(Sentry).to receive(:capture_exception)
        stub_teacher_training_api_providers_with_multiple_pages
        allow(TeacherTrainingPublicAPI::SyncCourses).to receive(:perform_in)
      end

      it 'raises an error when there are any updates' do
        described_class.call(incremental_sync: false)

        expect(Sentry).to have_received(:capture_exception)
                          .with(TeacherTrainingPublicAPI::FullSyncUpdateError.new('providers have been updated'))
                          .at_least(:once)
      end
    end

    context 'a previous year recruitment cycle' do
      let(:recruitment_cycle_year) { RecruitmentCycle.previous_year }
      let(:sync_provider) { instance_double(TeacherTrainingPublicAPI::SyncProvider) }

      before do
        allow(sync_provider).to receive(:call)
        allow(TeacherTrainingPublicAPI::SyncProvider)
          .to receive(:new)
          .with(provider_from_api: anything, recruitment_cycle_year: recruitment_cycle_year, delay_by: 6.minutes, incremental_sync: false)
          .and_return(sync_provider)
      end

      it 'calls sync provider with the previous year recruitment cycle' do
        stub_teacher_training_api_providers(recruitment_cycle_year: recruitment_cycle_year)
        described_class.call(recruitment_cycle_year: recruitment_cycle_year, incremental_sync: false)

        expect(sync_provider).to have_received(:call)
      end
    end

    context 'incremental sync' do
      let(:recruitment_cycle_year) { RecruitmentCycle.current_year }
      let(:sync_provider) { instance_double(TeacherTrainingPublicAPI::SyncProvider) }
      let(:updated_since) { Time.zone.now - 2.hours }

      before do
        allow(TeacherTrainingPublicAPI::SyncCheck).to receive(:updated_since).and_return(updated_since)
        allow(sync_provider).to receive(:call)
        allow(TeacherTrainingPublicAPI::SyncProvider)
          .to receive(:new)
            .with(provider_from_api: anything, recruitment_cycle_year: recruitment_cycle_year, delay_by: nil, incremental_sync: true)
            .and_return(sync_provider)
        stub_teacher_training_api_providers(
          recruitment_cycle_year: recruitment_cycle_year,
          filter_option: { 'filter[updated_since]' => updated_since },
        )
      end

      it 'calls sync provider' do
        described_class.call(incremental_sync: true)

        expect(sync_provider).to have_received(:call)
      end
    end
  end
end
