require 'rails_helper'

RSpec.describe CourseOption, type: :model do
  subject(:course_option) { create(:course_option) }

  describe 'a valid course option' do
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
    it 'returns only course options where invalidated_by_find is false' do
      expected_course_option = create(:course_option, invalidated_by_find: false)
      create(:course_option, invalidated_by_find: true)

      expect(CourseOption.selectable).to match_array [expected_course_option]
    end
  end
end
