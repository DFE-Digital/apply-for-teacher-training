require 'rails_helper'

RSpec.describe 'Candidate Interface - Redirects when reference is not requested yet' do
  include Devise::Test::IntegrationHelpers

  let(:candidate) { create(:candidate) }

  before do
    sign_in candidate
  end

  context 'when candidate has a requested reference' do
    it 'renders the page' do
      application_form = create(:application_form, submitted_at: Time.zone.now, candidate:)
      create(:application_choice, :accepted, application_form:)
      reference = create(:reference, :feedback_requested, application_form:)
      get candidate_interface_application_offer_dashboard_reference_path(reference)
      expect(response).to have_http_status(:ok)
    end
  end

  context 'when candidate did not request a reference yet' do
    it 'redirects to the check your answer and request reference page' do
      application_form = create(:application_form, submitted_at: Time.zone.now, candidate:)
      create(:application_choice, :accepted, application_form:)
      reference = create(:reference, :not_requested_yet, application_form:)
      get candidate_interface_application_offer_dashboard_reference_path(reference)
      expect(response).to redirect_to(candidate_interface_references_request_reference_review_path(reference))
    end
  end
end
