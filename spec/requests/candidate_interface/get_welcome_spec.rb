require 'rails_helper'

describe 'Candidate Interface - GET /candidate/welcome', type: :request do
  before do
    candidate = FactoryBot.create(:candidate)
    login_as(candidate)
  end

  context 'when without a token' do
    it 'returns a 200 response' do
      get '/candidate/welcome'

      expect(response).to have_http_status(200)
    end
  end

  context 'when with a token' do
    it 'redirects to itself to remove the token from URL' do
      get '/candidate/welcome?token=hoot'

      expect(response).to redirect_to(candidate_interface_welcome_path)
    end
  end
end
