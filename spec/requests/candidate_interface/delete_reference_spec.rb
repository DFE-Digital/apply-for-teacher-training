require 'rails_helper'

RSpec.describe 'Candidate Interface - Redirects acepted offer' do
  include Devise::Test::IntegrationHelpers

  let(:candidate) { create(:candidate) }

  before do
    sign_in candidate
  end

  context 'when deleting a reference from references review' do
    it 'destroys the reference and redirect to references review' do
      application_form = create(:application_form, recruitment_cycle_year: 2023, candidate:)
      reference = create(:reference, :feedback_requested, application_form:)

      delete candidate_interface_destroy_new_reference_path(reference)
      expect(response).to redirect_to(candidate_interface_references_review_path)
    end
  end

  context 'when deleting a nil reference' do
    it 'redirects to review page' do
      application_form = create(:application_form, recruitment_cycle_year: 2023, candidate:)
      reference = create(:reference, :feedback_requested, application_form:)
      reference.destroy

      delete candidate_interface_destroy_new_reference_path(reference)
      expect(response).to redirect_to(candidate_interface_references_review_path)
    end
  end
end
