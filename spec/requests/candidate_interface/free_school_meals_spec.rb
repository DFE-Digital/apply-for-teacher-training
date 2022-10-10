require 'rails_helper'

RSpec.describe 'GET', type: :request do
  include Devise::Test::IntegrationHelpers
  let(:candidate) { create(:candidate) }

  before do
    FeatureFlag.activate(:new_references_flow)
    sign_in candidate
  end

  context 'when candidate is eligible for free school meals' do
    it 'returns 200' do
      create(:completed_application_form, :eligible_for_free_school_meals, candidate:)

      get candidate_interface_edit_equality_and_diversity_free_school_meals_path

      expect(response).to have_http_status(:success)
    end
  end

  context 'when candidate is ineligible for free school meals' do
    it 'returns 404' do
      create(:completed_application_form, date_of_birth: Date.parse('1/10/1954'), candidate:)

      get candidate_interface_edit_equality_and_diversity_free_school_meals_path

      expect(response).to have_http_status(:not_found)
    end
  end
end
