require 'rails_helper'

RSpec.describe CourseSubject, type: :model do
  subject(:course_subject) { build(:course_subject) }

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:course_id).scoped_to(:subject_id) }
  end
end
