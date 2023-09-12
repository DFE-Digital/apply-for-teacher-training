require 'rails_helper'

RSpec.describe 'legacy applications cannot submit to continuous apps' do
  include Devise::Test::IntegrationHelpers
  let(:candidate) { create(:candidate, application_forms: [create(:application_form, :completed, submitted_at: nil, application_choices_count: 1)]) }
  let(:application) { candidate.application_forms.last }
  let(:choice) { application.application_choices.last }

  before { sign_in candidate }

  context 'when continuous applications', :continuous_applications do
    context 'when submitting to continuous applications' do
      it 'be successful' do
        post candidate_interface_continuous_applications_submit_course_choice_path(choice.id), params: {
          candidate_interface_continuous_applications_submit_application_form: { submit_answer: true },
        }
        expect(response).to redirect_to(candidate_interface_continuous_applications_choices_path)
      end
    end

    context 'when submitting to legacy applications endpoint' do
      it 'be not found' do
        post candidate_interface_application_submit_path
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  context 'when not continuous applications', continuous_applications: false do
    context 'when submitting to continuous applications' do
      it 'be not found' do
        post candidate_interface_continuous_applications_submit_course_choice_path(choice.id)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when submitting to legacy applications endpoint' do
      it 'be redirect' do
        post candidate_interface_application_submit_path
        expect(response).to redirect_to(candidate_interface_feedback_form_path)
      end
    end
  end
end
