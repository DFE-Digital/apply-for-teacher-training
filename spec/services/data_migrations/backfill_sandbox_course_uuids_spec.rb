require 'rails_helper'

RSpec.describe DataMigrations::BackfillSandboxCourseUuids do
  include TeacherTrainingPublicAPIHelper

  let(:provider) { create(:provider) }
  let(:up_to_date_course_uuid) { SecureRandom.uuid }
  let(:out_of_date_course_uuid) { SecureRandom.uuid }
  let(:new_course_uuid) { SecureRandom.uuid }
  let!(:up_to_date_course) { create(:course, provider:, uuid: up_to_date_course_uuid) }
  let!(:out_of_date_course) { create(:course, provider:, uuid: out_of_date_course_uuid) }

  before do
    allow(HostingEnvironment).to receive(:sandbox_mode?).and_return(true)

    stub_teacher_training_api_courses(
      provider_code: provider.code,
      recruitment_cycle_year: current_year,
      specified_attributes: [
        { code: up_to_date_course.code, uuid: up_to_date_course_uuid },
        { code: out_of_date_course.code, uuid: new_course_uuid },
      ],
    )
  end

  describe '#change', time: mid_cycle(2023) do
    context 'course uuid varies between TTAPI and apply' do
      it 'updates the uuid' do
        expect { described_class.new.change }
          .to change { out_of_date_course.reload.uuid }
          .from(out_of_date_course_uuid)
          .to(new_course_uuid)
      end
    end

    context 'course uuid does not vary between TTAPI and apply' do
      it 'does not update the uuid' do
        expect { described_class.new.change }
          .not_to(change { up_to_date_course.reload.uuid })
      end
    end
  end

  describe 'failing in non-sandbox environment' do
    before do
      allow(HostingEnvironment).to receive(:sandbox_mode?).and_return(false)
    end

    it 'throws an exception' do
      expect { described_class.new.change }.to raise_error(StandardError)
    end
  end

  describe 'continues if provider is not on the API' do
    before do
      allow(TeacherTrainingPublicAPI::Course).to receive(:where).with(year: 2023, provider_code: provider.code).and_raise(JsonApiClient::Errors::NotFound, '404')
    end

    it 'returns empty array' do
      expect(described_class.new.courses_for_provider(provider)).to be_empty
    end
  end
end
