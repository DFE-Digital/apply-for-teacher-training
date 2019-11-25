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

      expect(pick_site_form).to be_valid

      pick_site_form.save

      pick_site_form = CandidateInterface::PickSiteForm.new(
        application_form: application_form,
        course_option_id: create(:course_option).id,
      )

      expect(pick_site_form).not_to be_valid
    end
  end
end
