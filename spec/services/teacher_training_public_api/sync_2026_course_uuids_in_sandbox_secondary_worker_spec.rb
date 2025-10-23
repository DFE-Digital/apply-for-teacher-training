require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::Sync2026CourseUuidsInSandboxSecondaryWorker, :sidekiq do
  include TeacherTrainingPublicAPIHelper

  context 'sandbox mode' do
    before do
      allow(HostingEnvironment).to receive(:sandbox_mode?).and_return(true)
    end

    context 'api course exists and the UUID is the same as publish sandbox' do
      let(:api_uuid) { SecureRandom.uuid }
      let(:course) { create(:course, recruitment_cycle_year: 2026, uuid: api_uuid) }
      let(:provider) { course.provider }

      before do
        stub_teacher_training_api_courses(
          provider_code: provider.code,
          specified_attributes: [{ uuid: api_uuid, code: course.code, recruitment_cycle_year: 2026 }],
          recruitment_cycle_year: 2026,
        )
      end

      it 'does not update course' do
        original_uuid = course.uuid
        described_class.new.perform(provider.code)
        expect(course.reload.uuid).to eq original_uuid
      end
    end

    context 'api course exists and the UUID is different in publish sandbox' do
      let(:api_uuid) { SecureRandom.uuid }
      let(:course) { create(:course, recruitment_cycle_year: 2026, uuid: SecureRandom.uuid) }
      let!(:provider) { course.provider }

      before do
        stub_teacher_training_api_courses(
          provider_code: provider.code,
          specified_attributes: [{ uuid: api_uuid, code: course.code, recruitment_cycle_year: 2026 }],
          recruitment_cycle_year: 2026,
        )
      end

      it 'updates course to match publish sandbox' do
        provider_code = course.provider.code
        described_class.new.perform(provider_code)

        expect(course.reload.uuid).to eq api_uuid
      end
    end
  end
end
