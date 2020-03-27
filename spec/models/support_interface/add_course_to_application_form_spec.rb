require 'rails_helper'

RSpec.describe SupportInterface::AddCourseToApplicationForm, type: :model do
  describe '#valid?' do
    it 'is not valid if the course option does not exist' do
      application_form = build_stubbed(:application_form)
      form = SupportInterface::AddCourseToApplicationForm.new(application_form: application_form, course_option_id: 7125871235812)

      form.validate

      expect(form.errors.full_messages).to include "There's no course option with ID 7125871235812"
    end
  end
end
