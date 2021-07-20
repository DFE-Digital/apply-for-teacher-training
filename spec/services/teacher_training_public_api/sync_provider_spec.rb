require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::SyncProvider, sidekiq: true do
  include TeacherTrainingPublicAPIHelper

  describe '.call' do
    before do
      allow(TeacherTrainingPublicAPI::SyncCourses).to receive(:perform_async).and_return(true)
      described_class.new(provider_from_api: provider_from_api, recruitment_cycle_year: stubbed_recruitment_cycle_year).call(run_in_background: true)
    end

    context 'ingesting a brand new provider' do
      let(:provider_from_api) { fake_api_provider({ code: 'ABC' }) }

      it 'creates the provider' do
        provider = Provider.find_by(code: 'ABC')
        expect(provider).to be_present
      end

      it 'syncs the provider courses' do
        expect(TeacherTrainingPublicAPI::SyncCourses).to have_received(:perform_async).exactly(1).time
      end
    end

    context 'ingesting an existing provider' do
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
        expect(TeacherTrainingPublicAPI::SyncCourses).to have_received(:perform_async).with(
          provider_from_api.id,
          stubbed_recruitment_cycle_year,
        ).exactly(1).time
      end
    end
  end
end
