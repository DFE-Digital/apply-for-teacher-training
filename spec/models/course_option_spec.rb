require 'rails_helper'

RSpec.describe CourseOption, type: :model do
  describe 'a valid course option' do
    subject(:course_option) { create(:course_option) }

    it { is_expected.to belong_to :course }
    it { is_expected.to belong_to :site }
    it { is_expected.to validate_presence_of :vacancy_status }

    context 'when site and course have different providers' do
      subject(:course_option) { build(:course_option, site: site_for_different_provider) }

      let(:site_for_different_provider) { create :site }

      it 'is not valid' do
        expect(course_option).not_to be_valid
        expect(course_option.errors.keys).to include(:site)
      end
    end
  end

  describe '.selectable' do
    subject(:course_option) { create(:course_option) }

    it 'returns only course options where invalidated_by_find is false' do
      expected_course_option = create(:course_option, invalidated_by_find: false)
      create(:course_option, invalidated_by_find: true)

      expect(CourseOption.selectable).to match_array [expected_course_option]
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
        create(:course_option, :no_vacancies, course: course)

        expect(course_option_under_test.course_full?).to be false
      end

      it 'returns false if sibling course_options have vacancies' do
        create(:course_option, course: course)

        expect(course_option_under_test.course_full?).to be false
      end
    end

    context 'course option has no vacancies' do
      let(:course_option_under_test) { create(:course_option, :no_vacancies) }

      it 'returns true if sibling course_options have no vacancies' do
        create(:course_option, :no_vacancies, course: course)

        expect(course_option_under_test.course_full?).to be true
      end

      it 'returns false if sibling course_options have vacancies' do
        create(:course_option, course: course)

        expect(course_option_under_test.course_full?).to be false
      end
    end
  end
end
