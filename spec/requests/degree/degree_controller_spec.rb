require 'rails_helper'

RSpec.describe 'CandidateInterface::Degree::DegreeController' do
  include Devise::Test::IntegrationHelpers

  let(:candidate) { create(:candidate) }
  let(:application_form) { create(:application_form, candidate_id: candidate.id) }
  let(:application_qualification) { create(:degree_qualification, application_form_id: application_form.id) }

  before do
    sign_in candidate
  end

  describe 'edit', time: mid_cycle do
    it 'returns 404 if param not whitelisted' do
      get "/candidate/application/degrees/edit/#{application_qualification.id}/random-step"

      expect(response).to have_http_status(:not_found)
    end

    it 'redirects to correct path if param whitelisted' do
      CandidateInterface::DegreeWizard::VALID_STEPS.each do |step|
        get "/candidate/application/degrees/edit/#{application_qualification.id}/#{step}"

        expect(response).to redirect_to send("candidate_interface_degree_#{step}_path")
      end
    end
  end
end
