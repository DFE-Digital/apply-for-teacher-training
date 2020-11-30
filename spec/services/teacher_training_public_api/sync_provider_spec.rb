require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::SyncProvider, sidekiq: true do
  include TeacherTrainingPublicAPIHelper

  describe '.call' do
    context 'ingesting a brand new provider' do
      it 'just creates the provider without any courses' do
        provider_from_api = fake_api_provider(code: 'ABC')

        described_class.new(
          provider_from_api: provider_from_api,
          recruitment_cycle_year: RecruitmentCycle.current_year,
        ).call

        provider = Provider.find_by_code('ABC')

        expect(provider).to be_present
        expect(provider.courses).to be_blank
      end
    end

    context 'ingesting a provider configured to sync courses' do
      it 'assigns qualifications and program_type to an existing course' do
        provider = create :provider, code: 'ABC', sync_courses: true
        course = create(:course, code: 'ABC1', provider: provider)
        provider_from_api = fake_api_provider(code: 'ABC')

        stub_teacher_training_api_courses(
          provider_code: 'ABC',
          specified_attributes: [{
            code: 'ABC1',
            qualifications: %w[qts pgce],
            program_type: 'scitt_programme',
          }],
        )

        described_class.new(
          provider_from_api: provider_from_api,
          recruitment_cycle_year: RecruitmentCycle.current_year,
        ).call

        expect(course.reload.program_type).to eq 'scitt_programme'
        expect(course.reload.qualifications).to eq %w[qts pgce]
      end
    end
  end
end
