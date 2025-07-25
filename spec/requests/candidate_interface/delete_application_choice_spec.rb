require 'rails_helper'

RSpec.describe 'DELETE /candidate/application/continuous-applications/delete/:application_choice_id' do
  include Devise::Test::IntegrationHelpers

  let(:candidate) { create(:candidate) }
  let(:application_form) { create(:application_form, candidate:) }

  before do
    sign_in candidate
  end

  context 'when application is unsubmitted', time: mid_cycle do
    let(:application_choice) { create(:application_choice, :unsubmitted, application_form:) }

    it 'destroys the application choice and redirects to review' do
      delete candidate_interface_course_choices_confirm_destroy_course_choice_path(application_choice)
      expect(ApplicationChoice.exists?(application_choice.id)).to be_falsey
      expect(response).to redirect_to(candidate_interface_application_choices_path)
    end
  end

  context 'when application is submitted', time: mid_cycle do
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision, application_form:) }

    it 'does not destroy the application choice and redirects to review' do
      delete candidate_interface_course_choices_confirm_destroy_course_choice_path(application_choice)
      expect(ApplicationChoice.exists?(application_choice.id)).to be_truthy
      expect(response).to redirect_to(candidate_interface_application_choices_path)
    end
  end
end
