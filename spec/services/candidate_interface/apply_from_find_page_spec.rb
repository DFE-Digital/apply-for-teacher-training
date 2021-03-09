require 'rails_helper'

RSpec.describe CandidateInterface::ApplyFromFindPage do
  include TeacherTrainingPublicAPIHelper

  before do
    FeatureFlag.activate(:pilot_open)
    create(:course, :open_on_apply, code: 'ABC1', provider: create(:provider, code: 'ABC'))
  end

  describe '#candidate_has_application_in_wrong_cycle?' do
  end

  describe '#course_available_on_apply_and_candidate_signed_in?' do
    it 'is correct' do
      service = described_class.new(
        course_code: 'ABC1',
        provider_code: 'ABC',
        current_candidate: double,
      )

      expect(service.course_available_on_apply_and_candidate_signed_in?).to be true
    end
  end

  describe '#course_available_on_apply_and_candidate_not_signed_in?' do
    it 'is correct' do
      service = described_class.new(
        course_code: 'ABC1',
        provider_code: 'ABC',
        current_candidate: nil,
      )

      expect(service.course_available_on_apply_and_candidate_not_signed_in?).to be true
    end
  end

  describe '#course_available_on_apply_and_provider_not_on_ucas?' do
    it 'is correct' do
      create(:course, :open_on_apply, code: 'ABC1', provider: create(:provider, code: Provider::NOT_ACCEPTING_APPLICATIONS_ON_UCAS.first))

      service = described_class.new(
        course_code: 'ABC1',
        provider_code: Provider::NOT_ACCEPTING_APPLICATIONS_ON_UCAS.first,
      )

      expect(service.course_available_on_apply_and_provider_not_on_ucas?).to be true
    end
  end

  describe '#course_available_on_apply?' do
    it 'is correct' do
      service = described_class.new(
        course_code: 'ABC1',
        provider_code: 'ABC',
      )

      expect(service.course_available_on_apply?).to be true
    end
  end

  describe '#ucas_only?' do
    context 'the course is on apply' do
      it 'returns true' do
        create(:course, :ucas_only, code: 'DEF1', provider: create(:provider, code: 'ABC'))

        service = described_class.new(provider_code: 'ABC', course_code: 'DEF1')

        expect(service.ucas_only?).to be true
      end
    end

    context 'the course is not on apply' do
      before do
        stub_teacher_training_api_course(
          provider_code: 'A999',
          course_code: 'B999',
          specified_attributes: { name: 'potions' },
        )
        stub_teacher_training_api_sites(
          provider_code: 'A999',
          course_code: 'B999',
        )
      end

      it 'returns true' do
        service = described_class.new(provider_code: 'A999', course_code: 'B999')

        expect(service.ucas_only?).to be true
      end

      it 'loads the course details' do
        service = described_class.new(provider_code: 'A999', course_code: 'B999')

        expect(service.course.name).to eq('potions')
      end
    end
  end
end
