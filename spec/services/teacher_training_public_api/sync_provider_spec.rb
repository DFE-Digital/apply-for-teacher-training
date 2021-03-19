require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::SyncProvider, sidekiq: true do
  include TeacherTrainingPublicAPIHelper

  describe '.call' do
    context 'ingesting a brand new provider' do
      it 'just creates the provider without any courses' do
        provider_from_api = fake_api_provider({ code: 'ABC' })
        described_class.new(provider_from_api: provider_from_api, recruitment_cycle_year: stubbed_recruitment_cycle_year).call

        provider = Provider.find_by(code: 'ABC')
        expect(provider).to be_present
        expect(provider.courses).to be_blank
      end
    end

    context 'ingesting an existing provider not configured to sync courses' do
      before do
        @existing_provider = create :provider, code: 'ABC', sync_courses: false, name: 'Foobar College'
      end

      it 'correctly updates the provider but does not import any courses' do
        provider_from_api = fake_api_provider(code: 'ABC', name: 'ABC College')
        described_class.new(provider_from_api: provider_from_api, recruitment_cycle_year: stubbed_recruitment_cycle_year).call

        expect(@existing_provider.reload.courses).to be_blank
        expect(@existing_provider.reload.name).to eq 'ABC College'
      end

      it 'correctly updates the Provider#region_code' do
        provider_from_api = fake_api_provider(code: 'ABC', region_code: 'north_west')
        stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                                   course_code: 'ABC1',
                                                   course_attributes: [{ accredited_body_code: nil, study_mode: 'full_time' }],
                                                   site_code: 'A',
                                                   vacancy_status: 'full_time_vacancies')

        described_class.new(provider_from_api: provider_from_api, recruitment_cycle_year: stubbed_recruitment_cycle_year).call
        expect(Provider.count).to eq 1
        Provider.first.update!(region_code: 'london')

        described_class.new(provider_from_api: provider_from_api, recruitment_cycle_year: stubbed_recruitment_cycle_year).call
        expect(Provider.count).to eq 1
        expect(Provider.first.region_code).to eq 'north_west'
      end
    end

    context 'ingesting an existing provider configured to sync courses, sites and course_options' do
      it 'calls the Sync Courses job with the correct parameters' do
        existing_provider = create(:provider, sync_courses: true)
        provider_from_api = fake_api_provider(id: existing_provider.id, code: existing_provider.code)

        allow(TeacherTrainingPublicAPI::SyncCourses).to receive(:perform_async).and_return(true)

        sync_job = described_class.new(provider_from_api: provider_from_api, recruitment_cycle_year: stubbed_recruitment_cycle_year)
        sync_job.call(run_in_background: true)

        expect(TeacherTrainingPublicAPI::SyncCourses).to have_received(:perform_async).with(provider_from_api.id, stubbed_recruitment_cycle_year).exactly(1).time
      end
    end
  end
end
