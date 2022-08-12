require 'rails_helper'

RSpec.describe 'Candidate Interface - Redirects when reference is not requested yet', type: :request do
  include Devise::Test::IntegrationHelpers
  let(:candidate) { create(:candidate) }

  before do
    sign_in candidate
    FeatureFlag.activate(:new_references_flow)
  end

  context 'when candidate has a requested reference' do
    it 'renders the page' do
      application_form = create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: 2023, candidate: candidate)
      create(:application_choice, :with_accepted_offer, application_form: application_form)
      reference = create(:reference, :feedback_requested, application_form: application_form)
      get candidate_interface_application_offer_dashboard_reference_path(reference)
      expect(response.status).to be(200)
    end
  end

  context 'when candidate did not request a reference yet' do
    it 'redirects to the check your answer and request reference page' do
      application_form = create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: 2023, candidate: candidate)
      create(:application_choice, :with_accepted_offer, application_form: application_form)
      reference = create(:reference, :not_requested_yet, application_form: application_form)
      get candidate_interface_application_offer_dashboard_reference_path(reference)
      expect(response).to redirect_to(candidate_interface_new_references_request_reference_review_path(reference))
    end
  end
end
