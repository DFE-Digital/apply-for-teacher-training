require 'rails_helper'

RSpec.describe Course, type: :model do
  describe 'a valid course' do
    subject(:course) { create(:course) }

    it { is_expected.to validate_presence_of :level }
    it { is_expected.to validate_uniqueness_of(:code).scoped_to(%i[recruitment_cycle_year provider_id]) }
  end

  describe '#currently_has_both_study_modes_available?' do
    let(:course) { build(:course) }

    it 'is true when a course has full time and part time course options' do
      create(:course_option, :full_time, course: course)
      create(:course_option, :part_time, course: course)

      expect(course.currently_has_both_study_modes_available?).to be true
    end

    it 'is false when a course only has availability on one study mode' do
      create(:course_option, :full_time, course: course)
      create(:course_option, :part_time, :no_vacancies, course: course)

      expect(course.currently_has_both_study_modes_available?).to be false
    end
  end

  describe '#available_study_modes_from_options' do
    it 'returns an array of unique study modes for a courses course options' do
      course_option1 = build_stubbed(:course_option, :full_time)
      course_option2 = build_stubbed(:course_option, :full_time)
      course_option3 = build_stubbed(:course_option, :part_time)
      course = build_stubbed(:course, course_options: [course_option1, course_option2, course_option3])

      expect(course.available_study_modes_from_options).to eq [course_option1.study_mode, course_option3.study_mode]
    end

    it 'does not return course_options which have been invalidated by the TTAPI' do
      valid_course_option = build_stubbed(:course_option, :full_time)
      invalid_course_option = build_stubbed(:course_option, :part_time, site_still_valid: false)
      course = build_stubbed(:course, course_options: [valid_course_option, invalid_course_option])

      expect(course.available_study_modes_from_options).to eq [valid_course_option.study_mode]
    end
  end

  describe '#available_study_modes_with_vacancies' do
    let(:course) { build(:course) }

    it 'returns an array of unique study modes for course options with available vacancies' do
      create_list(:course_option, 2, :no_vacancies, :full_time, course: course)
      create(:course_option, :part_time, course: course)

      expect(course.available_study_modes_with_vacancies).to eq %w[part_time]
    end

    it 'returns an array of unique study modes for course options with valid sites' do
      create(:course_option, :full_time, course: course)
      create(:course_option, :part_time, course: course, site_still_valid: false)

      expect(course.available_study_modes_from_options).to eq %w[full_time]
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

  describe '#in_previous_cycle' do
    it 'returns nil when there is no equivalent in the previous cycle' do
      course = create(:course)

      expect(course.in_previous_cycle).to be_nil
    end

    it 'returns the equivalent in the previous cycle when there is one' do
      provider = create(:provider)
      course_in_previous_cycle = create(:course, code: 'ABC', provider: provider, recruitment_cycle_year: 2019)

      course = create(:course, code: 'ABC', provider: provider, recruitment_cycle_year: 2020)

      expect(course.in_previous_cycle).to eq course_in_previous_cycle
    end
  end

  describe '#subject_codes' do
    let(:course) { create(:course, subjects: [create(:subject, code: '01'), create(:subject, code: '9X')]) }

    it 'returns an array with all the codes of the course subjects' do
      expect(course.subject_codes).to contain_exactly('01', '9X')
    end
  end

  describe '#ratifying_provider' do
    context 'when there is an accredited provider set' do
      let(:course) { build(:course, accredited_provider: build(:provider)) }

      it 'returns the accredited provider' do
        expect(course.ratifying_provider).to eq(course.accredited_provider)
      end
    end

    context 'when there is no accredited provider set' do
      let(:course) { build(:course) }

      it 'returns the provider' do
        expect(course.ratifying_provider).to eq(course.provider)
      end
    end
  end

  describe '#open!' do
    it 'sets both open_on_apply and opened_on_apply_at' do
      Timecop.freeze do
        course = create(:course)
        course.open!
        expect(course.open_on_apply).to be(true)
        expect(course.opened_on_apply_at).to eq(Time.zone.now)
      end
    end

    it 'does not update the timestamp if course already open' do
      course = create(:course, :open_on_apply)
      expect { course.open! }.not_to change(course, :opened_on_apply_at)
    end
  end
end
