require 'rails_helper'

RSpec.describe 'Candidate Interface - Request references', type: :request do
  include Devise::Test::IntegrationHelpers
  let(:candidate) { create(:candidate) }

  before do
    sign_in candidate
    FeatureFlag.activate(:new_references_flow)
  end

  context 'when requested a non existent reference' do
    it 'renders not found' do
      get candidate_interface_new_references_request_reference_review_path(12345)

      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when candidate has reference provided' do
    it 'renders not found' do
      application_form = create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: 2023, candidate: candidate)
      create(:application_choice, :with_accepted_offer, application_form: application_form)
      reference = create(:reference, :feedback_provided, application_form: application_form)

      post candidate_interface_new_references_request_reference_feedback_requested_path(reference)
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when candidate did not request a reference yet' do
    it 'sets reference as requested' do
      application_form = create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: 2023, candidate: candidate)
      create(:application_choice, :with_accepted_offer, application_form: application_form)
      reference = create(:reference, :not_requested_yet, application_form: application_form)

      post candidate_interface_new_references_request_reference_feedback_requested_path(reference)
      expect(reference.reload).to be_feedback_requested
      expect(response).to redirect_to(candidate_interface_application_offer_dashboard_path)
    end
  end
end
