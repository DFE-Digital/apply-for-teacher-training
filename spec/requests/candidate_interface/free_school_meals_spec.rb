require 'rails_helper'

RSpec.describe 'GET' do
  include Devise::Test::IntegrationHelpers

  let(:candidate) { create(:candidate) }

  before do
    sign_in candidate
  end

  context 'when candidate is asked about free school meals', time: mid_cycle do
    it 'returns 200' do
      create(:completed_application_form, :eligible_for_free_school_meals, candidate:)

      get candidate_interface_edit_equality_and_diversity_free_school_meals_path

      expect(response).to have_http_status(:ok)
    end
  end

  context 'when candidate is not asked about free school meals', time: mid_cycle do
    it 'returns 302' do
      create(:completed_application_form, date_of_birth: Date.new(1954, 10, 1), candidate:)

      get candidate_interface_edit_equality_and_diversity_free_school_meals_path

      expect(response).to redirect_to(candidate_interface_review_equality_and_diversity_path)
      expect(response).to have_http_status(:found)
    end
  end
end
