require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::Sync2026CourseUuidsInSandbox, :sidekiq do
  include TeacherTrainingPublicAPIHelper

  context 'not production' do
    before do
      allow(HostingEnvironment).to receive(:production?).and_return false
      allow(TeacherTrainingPublicAPI::Sync2026CourseUuidsInSandboxSecondaryWorker).to receive(:perform_async)
    end

    context 'provider has 2026 courses' do
      let(:course) { create(:course, recruitment_cycle_year: 2026) }

      it 'calls the secondary worker' do
        provider = course.provider
        described_class.new.perform

        expect(TeacherTrainingPublicAPI::Sync2026CourseUuidsInSandboxSecondaryWorker)
          .to have_received(:perform_async)
                .with(provider.code)
      end
    end

    context 'provider does not have 2026 courses' do
      let(:course) { create(:course, recruitment_cycle_year: 2025) }

      it 'does not call the secondary worker' do
        provider = course.provider
        described_class.new.perform

        expect(TeacherTrainingPublicAPI::Sync2026CourseUuidsInSandboxSecondaryWorker)
          .not_to have_received(:perform_async)
                .with(provider.code)
      end
    end
  end

  context 'production' do
    before do
      allow(HostingEnvironment).to receive(:production?).and_return true
      allow(TeacherTrainingPublicAPI::Sync2026CourseUuidsInSandboxSecondaryWorker).to receive(:perform_async)
    end

    context 'provider has 2026 courses' do
      let(:course) { create(:course, recruitment_cycle_year: 2026) }

      it 'does not call secondary worker' do
        provider = course.provider
        described_class.new.perform

        expect(TeacherTrainingPublicAPI::Sync2026CourseUuidsInSandboxSecondaryWorker)
          .not_to have_received(:perform_async)
                    .with(provider.code)
      end
    end
  end
end
