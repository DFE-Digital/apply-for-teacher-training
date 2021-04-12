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
        expect(course_option.errors.attribute_names).to include(:site)
      end
    end
  end

  describe 'delegators' do
    it { is_expected.to delegate_method(:name).to(:site).with_prefix }
    it { is_expected.to delegate_method(:full_address).to(:site).with_prefix }
  end

  describe '.selectable' do
    subject(:course_option) { create(:course_option) }

    it 'returns only course options where site_still_valid is true' do
      expected_course_option = create(:course_option, site_still_valid: true)
      create(:course_option, site_still_valid: false)

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

  describe '#course_closed_on_apply?' do
    it 'returns true if course is not open on apply' do
      option = build_stubbed(
        :course_option,
        course: build_stubbed(:course, open_on_apply: false),
      )
      expect(option.course_closed_on_apply?).to be true
    end

    it 'returns false if course is open on apply' do
      option = build_stubbed(
        :course_option,
        course: build_stubbed(:course, open_on_apply: true),
      )
      expect(option.course_closed_on_apply?).to be false
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

  describe '#course_withdrawn?' do
    context 'when a course options course has been withdrawn' do
      it 'returns true' do
        course = create(:course, withdrawn: true)
        course_option = create(:course_option, course: course)

        expect(course_option.course_withdrawn?).to be true
      end
    end

    context 'when a course options course has not been withdrawn' do
      it 'returns false' do
        course = create(:course, withdrawn: false)
        course_option = create(:course_option, course: course)

        expect(course_option.course_withdrawn?).to be false
      end
    end
  end
end
