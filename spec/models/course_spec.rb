require 'rails_helper'

RSpec.describe Course, type: :model do
  describe 'a valid course' do
    subject(:course) { create(:course) }

    it { is_expected.to validate_presence_of :level }
    it { is_expected.to validate_uniqueness_of(:code).scoped_to(%i[recruitment_cycle_year provider_id]) }
  end

  describe '#both_study_modes_available?' do
    it 'is true when the study_mode value indicates both modes are available' do
      course = build_stubbed(:course, study_mode: 'full_time_or_part_time')
      expect(course.both_study_modes_available?).to be true
    end

    it 'is false when the study_mode value is a specific mode' do
      course = build_stubbed(:course, study_mode: 'full_time')
      expect(course.both_study_modes_available?).to be false
      course.study_mode = 'part_time'
      expect(course.both_study_modes_available?).to be false
    end
  end

  describe '#full?' do
    subject(:course) { create(:course) }

    context 'when there are no course options' do
      it 'returns true' do
        expect(course.full?).to be true
      end
    end

    context 'when a subset of course options have vacancies' do
      before do
        create(:course_option, course: course, vacancy_status: 'vacancies')
        create(:course_option, course: course, vacancy_status: 'no_vacancies')
      end

      it 'returns false' do
        expect(course.full?).to be false
      end
    end

    context 'when no course options have vacancies' do
      before do
        create(:course_option, course: course, vacancy_status: 'no_vacancies')
        create(:course_option, course: course, vacancy_status: 'no_vacancies')
      end

      it 'returns false' do
        expect(course.full?).to be true
      end
    end
  end
end
