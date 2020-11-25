require 'rails_helper'

RSpec.describe TeacherTrainingAPI::SyncProvider, sidekiq: true do
  include TeacherTrainingAPIHelper

  describe '.call' do
    context 'ingesting a brand new provider' do
      it 'just creates the provider without any courses' do
        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)

        provider = Provider.find_by_code('ABC')

        expect(provider).to be_present
        expect(provider.courses).to be_blank
      end
    end

    context 'ingesting a provider configured to sync courses' do
      it 'assigns qualifications and program_type to an existing course' do
        provider = create :provider, code: 'ABC', sync_courses: true
        course = create(:course, code: 'ABC1', provider: provider)

        stub_teacher_training_api_provider(
          provider_code: 'ABC',
        )

        stub_teacher_training_api_courses(
          provider_code: 'ABC',
          specified_attributes: [{
            code: 'ABC1',
            qualifications: %w[qts pgce],
            program_type: 'scitt_programme',
          }],
        )

        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: RecruitmentCycle.current_year)

        expect(course.reload.program_type).to eq 'scitt_programme'
        expect(course.reload.qualifications).to eq %w[qts pgce]
      end
    end
  end
end
