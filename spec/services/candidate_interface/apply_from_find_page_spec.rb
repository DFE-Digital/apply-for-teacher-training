require 'rails_helper'

RSpec.describe CandidateInterface::ApplyFromFindPage do
  include TeacherTrainingPublicAPIHelper

  before do
    create(:course, :open, code: 'ABC1', provider: create(:provider, code: 'ABC'))
  end

  describe '#candidate_has_application_in_wrong_cycle?' do
    let(:current_year) { RecruitmentCycleTimetable.current_year }
    let(:previous_year) { RecruitmentCycleTimetable.previous_year }

    context 'when the application is not in the wrong cycle' do
      it 'is false' do
        candidate = create(:candidate)
        create(:application_form, recruitment_cycle_year: current_year, candidate:)

        service = described_class.new(
          course_code: 'ABC1',
          provider_code: 'ABC',
          current_candidate: candidate,
        )

        expect(service.candidate_has_application_in_wrong_cycle?).to be false
      end
    end

    context 'when the course is in the Apply database already' do
      it 'is true' do
        candidate = create(:candidate)
        create(:application_form, recruitment_cycle_year: previous_year, candidate:)

        service = described_class.new(
          course_code: 'ABC1',
          provider_code: 'ABC',
          current_candidate: candidate,
        )

        expect(service.candidate_has_application_in_wrong_cycle?).to be true
      end
    end

    context 'when the course is not in the Apply database' do
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

      it 'is true' do
        candidate = create(:candidate)
        create(:application_form, recruitment_cycle_year: previous_year, candidate:)

        service = described_class.new(
          course_code: 'B999',
          provider_code: 'A999',
          current_candidate: candidate,
        )

        expect(service.candidate_has_application_in_wrong_cycle?).to be true
      end
    end
  end

  describe '#course_in_apply_database_and_candidate_signed_in?' do
    it 'is correct' do
      service = described_class.new(
        course_code: 'ABC1',
        provider_code: 'ABC',
        current_candidate: double,
      )

      expect(service.course_in_apply_database_and_candidate_signed_in?).to be true
    end
  end

  describe '#course_available_on_apply_and_candidate_not_signed_in?' do
    it 'is correct' do
      service = described_class.new(
        course_code: 'ABC1',
        provider_code: 'ABC',
        current_candidate: nil,
      )

      expect(service.course_in_apply_database_and_candidate_not_signed_in?).to be true
    end
  end
end
