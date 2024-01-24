require 'rails_helper'

RSpec.describe 'Submit to continuous apps' do
  include Devise::Test::IntegrationHelpers
  let(:candidate) do
    create(
      :candidate,
      application_forms: [
        create(:application_form, :completed, submitted_at: nil, application_choices_count: 1),
      ],
    )
  end
  let(:application) { candidate.application_forms.last }
  let(:choice) { application.application_choices.last }

  before { sign_in candidate }

  context 'when submitting to continuous applications' do
    it 'be successful' do
      post candidate_interface_continuous_applications_submit_course_choice_path(choice.id), params: {
        candidate_interface_continuous_applications_submit_application_form: { submit_answer: true },
      }
      expect(response).to redirect_to(candidate_interface_continuous_applications_choices_path)
    end
  end
end
