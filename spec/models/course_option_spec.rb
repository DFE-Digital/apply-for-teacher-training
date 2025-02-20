require 'rails_helper'

RSpec.describe CourseOption do
  describe 'a valid course option' do
    subject(:course_option) { create(:course_option) }

    it { is_expected.to belong_to :course }
    it { is_expected.to validate_presence_of :vacancy_status }

    context 'when site and course have different providers' do
      subject(:course_option) { build(:course_option, site: site_for_different_provider) }

      let(:site_for_different_provider) { create(:site) }

      it 'is not valid' do
        expect(course_option).not_to be_valid
        expect(course_option.errors.attribute_names).to include(:site)
      end
    end
  end

  describe 'has_many :current_application_choices' do
    let(:current_course_option) { create(:course_option) }
    let(:application_choice) { create(:application_choice, current_course_option:) }

    it 'returns application choices for which the course option is the current course option' do
      expect(current_course_option.current_application_choices).to match_array(application_choice)
    end
  end

  describe 'delegators' do
    it { is_expected.to delegate_method(:name).to(:site).with_prefix }
    it { is_expected.to delegate_method(:full_address).to(:site).with_prefix }
    it { is_expected.to delegate_method(:postcode).to(:site).with_prefix }
  end

  describe '.selectable' do
    subject(:course_option) { create(:course_option) }

    it 'returns only course options where site_still_valid is true' do
      expected_course_option = create(:course_option, site_still_valid: true)
      create(:course_option, site_still_valid: false)

      expect(described_class.selectable).to contain_exactly(expected_course_option)
    end
  end

  describe '#course_not_available?' do
    it 'returns true if course is not exposed in find' do
      option = build_stubbed(
        :course_option,
        course: build_stubbed(:course, exposed_in_find: false),
      )
      expect(option.course_not_available?).to be true
    end

    it 'returns false if course is exposed in find' do
      option = build_stubbed(
        :course_option,
        course: build_stubbed(:course, exposed_in_find: true),
      )
      expect(option.course_not_available?).to be false
    end
  end

  describe '#course_full?' do
    let(:course) { course_option_under_test.course }

    context 'course option has vacancies' do
      let(:course_option_under_test) { create(:course_option) }

      it 'returns false if sibling course_options have no vacancies' do
        create(:course_option, :no_vacancies, course:)

        expect(course_option_under_test.course_full?).to be false
      end

      it 'returns false if sibling course_options have vacancies' do
        create(:course_option, course:)

        expect(course_option_under_test.course_full?).to be false
      end
    end

    context 'course option has no vacancies' do
      let(:course_option_under_test) { create(:course_option, :no_vacancies) }

      it 'returns true if sibling course_options have no vacancies' do
        create(:course_option, :no_vacancies, course:)

        expect(course_option_under_test.course_full?).to be true
      end

      it 'returns false if sibling course_options have vacancies' do
        create(:course_option, course:)

        expect(course_option_under_test.course_full?).to be false
      end
    end
  end

  describe '#course_withdrawn?' do
    context 'when a course options course has been withdrawn' do
      it 'returns true' do
        course = create(:course, withdrawn: true)
        course_option = create(:course_option, course:)

        expect(course_option.course_withdrawn?).to be true
      end
    end

    context 'when a course options course has not been withdrawn' do
      it 'returns false' do
        course = create(:course, withdrawn: false)
        course_option = create(:course_option, course:)

        expect(course_option.course_withdrawn?).to be false
      end
    end
  end

  describe '#in_previous_cycle' do
    let(:site_current_cycle) { create(:site) }
    let(:course_current_cycle) { create(:course, provider: site_current_cycle.provider) }
    let!(:course_option_current_cycle) { create(:course_option, site: site_current_cycle, course: course_current_cycle) }

    it 'returns the correct course option in the previous cycle' do
      site_next_cycle = create(:site, provider: site_current_cycle.provider, code: site_current_cycle.code)
      course_next_cycle = create(:course, provider: site_current_cycle.provider, recruitment_cycle_year: RecruitmentCycle.previous_year, code: course_current_cycle.code)
      course_option_next_cycle = create(:course_option, site: site_next_cycle, course: course_next_cycle)

      expect(course_option_current_cycle.in_previous_cycle).to eq(course_option_next_cycle)
    end

    it 'returns no course option if it does not exist in the previous cycle' do
      site_next_cycle = create(:site, provider: site_current_cycle.provider, code: 'AnotherCode')
      course_next_cycle = create(:course, provider: site_current_cycle.provider, recruitment_cycle_year: RecruitmentCycle.previous_year, code: course_current_cycle.code)
      create(:course_option, site: site_next_cycle, course: course_next_cycle)

      expect(course_option_current_cycle.in_previous_cycle).to be_nil
    end

    it 'ignores duplicate site codes in the same cycle and returns correct course option' do
      site_next_cycle = create(:site, provider: site_current_cycle.provider, code: site_current_cycle.code)
      course_next_cycle = create(:course, provider: site_current_cycle.provider, recruitment_cycle_year: RecruitmentCycle.previous_year, code: course_current_cycle.code)
      course_option_next_cycle = create(:course_option, site: site_next_cycle, course: course_next_cycle)

      another_site_next_cycle = create(:site, provider: site_current_cycle.provider, code: site_current_cycle.code)
      another_course_next_cycle = create(:course, provider: site_current_cycle.provider, recruitment_cycle_year: RecruitmentCycle.previous_year)
      create(:course_option, site: another_site_next_cycle, course: another_course_next_cycle)

      expect(course_option_current_cycle.in_previous_cycle).to eq(course_option_next_cycle)
    end
  end

  describe '#in_next_cycle' do
    let(:site_current_cycle) { create(:site) }
    let(:course_current_cycle) { create(:course, provider: site_current_cycle.provider) }
    let!(:course_option_current_cycle) { create(:course_option, site: site_current_cycle, course: course_current_cycle) }

    it 'returns the correct course option in the next cycle' do
      site_next_cycle = create(:site, provider: site_current_cycle.provider, code: site_current_cycle.code)
      course_next_cycle = create(:course, provider: site_current_cycle.provider, recruitment_cycle_year: RecruitmentCycle.next_year, code: course_current_cycle.code)
      course_option_next_cycle = create(:course_option, site: site_next_cycle, course: course_next_cycle)

      expect(course_option_current_cycle.in_next_cycle).to eq(course_option_next_cycle)
    end

    it 'returns no course option if it does not exist in the next cycle' do
      site_next_cycle = create(:site, provider: site_current_cycle.provider, code: 'AnotherCode')
      course_next_cycle = create(:course, provider: site_current_cycle.provider, recruitment_cycle_year: RecruitmentCycle.next_year, code: course_current_cycle.code)
      create(:course_option, site: site_next_cycle, course: course_next_cycle)

      expect(course_option_current_cycle.in_next_cycle).to be_nil
    end

    it 'ignores duplicate site codes in the same cycle and returns correct course option' do
      site_next_cycle = create(:site, provider: site_current_cycle.provider, code: site_current_cycle.code)
      course_next_cycle = create(:course, provider: site_current_cycle.provider, recruitment_cycle_year: RecruitmentCycle.next_year, code: course_current_cycle.code)
      course_option_next_cycle = create(:course_option, site: site_next_cycle, course: course_next_cycle)

      another_site_next_cycle = create(:site, provider: site_current_cycle.provider, code: site_current_cycle.code)
      another_course_next_cycle = create(:course, provider: site_current_cycle.provider, recruitment_cycle_year: RecruitmentCycle.next_year)
      create(:course_option, site: another_site_next_cycle, course: another_course_next_cycle)

      expect(course_option_current_cycle.in_next_cycle).to eq(course_option_next_cycle)
    end
  end
end
