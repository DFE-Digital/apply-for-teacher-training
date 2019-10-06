require 'rails_helper'

describe 'Candidate Interface - Errors', type: :request do
  describe 'Not found (404)' do
    context 'GET /404' do
      it 'returns the not found page' do
        get '/404'

        expect(response).to have_http_status(:not_found)
        expect(response.header['Content-Type']).to include 'text/html'
        expect(response.body).to include(t('page_titles.not_found'))
      end
    end

    context 'GET non-existent page' do
      it 'returns the not found page' do
        get '/meow-woof-baaa-ssss'

        expect(response).to have_http_status(:not_found)
        expect(response.header['Content-Type']).to include 'text/html'
        expect(response.body).to include(t('page_titles.not_found'))
      end
    end
  end
end
