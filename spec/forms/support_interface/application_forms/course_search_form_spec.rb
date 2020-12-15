require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::CourseSearchForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:course_code) }
  end
end
