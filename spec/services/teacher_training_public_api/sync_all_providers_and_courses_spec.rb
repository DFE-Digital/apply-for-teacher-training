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
        described_class.call

        expect(described_class).to have_received(:sync_providers).exactly(3).times
      end
    end

    context 'a previous year recruitment cycle' do
      let(:recruitment_cycle_year) { RecruitmentCycle.previous_year }
      let(:sync_provider) { instance_double(TeacherTrainingPublicAPI::SyncProvider) }

      before do
        allow(sync_provider).to receive(:call)
        allow(TeacherTrainingPublicAPI::SyncProvider)
          .to receive(:new)
          .with(provider_from_api: anything, recruitment_cycle_year: recruitment_cycle_year)
          .and_return(sync_provider)
      end

      it 'calls sync provider with the previous year recruitment cycle' do
        stub_teacher_training_api_providers(recruitment_cycle_year: recruitment_cycle_year)
        described_class.call(recruitment_cycle_year: recruitment_cycle_year)

        expect(sync_provider).to have_received(:call)
      end
    end
  end
end
