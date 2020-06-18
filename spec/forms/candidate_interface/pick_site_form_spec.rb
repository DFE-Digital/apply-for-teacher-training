require 'rails_helper'

RSpec.describe CandidateInterface::PickSiteForm, type: :model do
  describe '#valid?' do
    it 'checks if the user has no more than 3 choices' do
      application_form = create(:application_form)
      application_form.application_choices << create(:application_choice)
      application_form.application_choices << create(:application_choice)

      pick_site_form = CandidateInterface::PickSiteForm.new(
        application_form: application_form,
        course_option_id: create(:course_option).id,
      )

      expect(pick_site_form).to be_valid(:save)

      pick_site_form.save

      pick_site_form = CandidateInterface::PickSiteForm.new(
        application_form: application_form,
        course_option_id: create(:course_option).id,
      )

      expect(pick_site_form).not_to be_valid(:save)
    end
  end

  describe '#update' do
    it 'updates the course_option for an existing course choice' do
      application_choice = create(:application_choice)
      new_course_option = create(:course_option)

      expect(application_choice.course_option.id).not_to eq(new_course_option.id)

      CandidateInterface::PickSiteForm.new(
        application_form: application_choice.application_form,
        course_option_id: new_course_option.id,
      ).update(application_choice)

      expect(application_choice.course_option.id).to eq(new_course_option.id)
    end
  end
end
