require 'rails_helper'

RSpec.describe 'Candidate Interface - GET /candidate/application', type: :request do
  before do
    candidate = FactoryBot.create(:candidate)
    login_as(candidate)
  end

  context 'when without a token' do
    it 'returns a 200 response' do
      get '/candidate/application'

      expect(response).to have_http_status(200)
    end
  end

  context 'when with a token' do
    it 'redirects to itself to remove the token from URL' do
      get '/candidate/application?token=hoot'

      expect(response).to redirect_to(candidate_interface_application_form_path)
    end
  end
end
