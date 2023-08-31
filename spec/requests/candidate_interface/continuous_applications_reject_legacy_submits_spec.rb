require 'rails_helper'

RSpec.describe 'legacy applications cannot submit to continuous apps' do
  include Devise::Test::IntegrationHelpers
  let(:candidate) { create(:candidate, application_forms: [create(:application_form, :completed, application_choices_count: 1)]) }
  let(:application) { candidate.application_forms.last }
  let(:choice) { application.application_choices.last }

  before { sign_in candidate }

  context 'when continuous applications', continuous_applications: true do
    it 'be successful' do
      post candidate_interface_continuous_applications_submit_course_choice_path(choice.id), params: {
        candidate_interface_continuous_applications_submit_application_form: { submit_answer: true },
      }
      expect(response).to redirect_to(candidate_interface_continuous_applications_choices_path)
    end
  end

  context 'when not continuous applications', continuous_applications: false do
    it 'be not found' do
      post candidate_interface_continuous_applications_submit_course_choice_path(choice.id)
      expect(response).to have_http_status(:not_found)
    end
  end
end
