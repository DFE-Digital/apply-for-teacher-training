require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::SyncProvider, :sidekiq do
  include TeacherTrainingPublicAPIHelper

  let(:delay_by) { nil }

  describe '.call' do
    let(:incremental_sync) { true }

    before do
      allow(TeacherTrainingPublicAPI::SyncCourses).to receive(:perform_in).and_return(true)
    end

    context 'ingesting a brand new provider' do
      let(:provider_from_api) { fake_api_provider({ code: 'ABC' }) }

      before do
        described_class.new(
          provider_from_api:,
          recruitment_cycle_year: stubbed_recruitment_cycle_year,
          delay_by:,
          incremental_sync:,
        ).call(run_in_background: true)
      end

      it 'creates the provider' do
        provider = Provider.find_by(code: 'ABC')
        expect(provider).to be_present
      end

      it 'syncs the provider courses' do
        expect(TeacherTrainingPublicAPI::SyncCourses).to have_received(:perform_in).exactly(1).time
      end

      context 'when latitude and longitude values are missing' do
        let(:provider_from_api) { fake_api_provider({ code: 'ABC', latitude: nil, longitude: nil }) }

        it 'handles missing latitude and longitude values' do
          provider = Provider.find_by(code: 'ABC')
          expect(provider.latitude).to be_blank
        end
      end
    end

    context 'ingesting an existing provider' do
      before do
        described_class.new(
          provider_from_api:,
          recruitment_cycle_year: stubbed_recruitment_cycle_year,
          delay_by:,
          incremental_sync:,
        ).call(run_in_background: true)
      end

      let!(:existing_provider) do
        create(:provider, code: 'ABC', name: 'Foobar College', region_code: 'london')
      end
      let(:provider_from_api) { fake_api_provider(id: existing_provider.id, code: existing_provider.code, name: 'ABC College', region_code: 'north_west') }

      it 'correctly updates the provider' do
        expect(existing_provider.reload.name).to eq('ABC College')
      end

      it 'correctly updates the Provider#region_code' do
        expect(existing_provider.reload.region_code).to eq('north_west')
      end

      it 'calls the Sync Courses job with the correct parameters' do
        expect(TeacherTrainingPublicAPI::SyncCourses).to have_received(:perform_in).with(
          nil,
          provider_from_api.id,
          stubbed_recruitment_cycle_year,
          true,
        ).exactly(1).time
      end

      context 'when delay set for running background job' do
        let(:delay_by) { 2.minutes }

        it 'calls the Sync Courses job with the correct delay time' do
          expect(TeacherTrainingPublicAPI::SyncCourses).to have_received(:perform_in).with(
            delay_by,
            provider_from_api.id,
            stubbed_recruitment_cycle_year,
            true,
          ).exactly(1).time
        end
      end
    end
  end
end
