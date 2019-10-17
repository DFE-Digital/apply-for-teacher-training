require 'rails_helper'

RSpec.describe CourseOption, type: :model do
  subject { create(:course_option) }

  describe 'a valid course option' do
    it { is_expected.to belong_to :course }
    it { is_expected.to belong_to :site }
    it { is_expected.to validate_presence_of :vacancy_status }
  end
end
