require 'rails_helper'

RSpec.describe CandidateInterface::PrefillApplicationFormController do
  include Devise::Test::IntegrationHelpers

  let(:candidate) { create(:candidate) }

  before { sign_in candidate }

  context 'when the candidate already has a non-blank application form' do
    let!(:application_form) { create(:application_form, :minimum_info, candidate:, created_at: 1.day.ago) }

    it 'redirects to the application form page' do
      get candidate_interface_prefill_path

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(candidate_interface_details_path)
    end
  end

  context 'when the candidate has a blank application form' do
    let!(:application_form) { create(:application_form, :minimum_info, candidate:) }

    it 'does not redirect to the application form page' do
      get candidate_interface_prefill_path

      expect(response).to have_http_status(:ok)
    end
  end
end
