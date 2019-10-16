require 'rails_helper'

RSpec.describe 'Candidate Interface - Errors', type: :request do
  describe 'Not found (404)' do
    context 'GET /404' do
      it 'returns the not found page' do
        get '/404'

        expect(response).to have_http_status(:not_found)
        expect(response.header['Content-Type']).to include 'text/html'
        expect(response.body).to include(t('page_titles.not_found'))
      end

      it 'returns the HTML not found page for other formats too' do
        get '/404.css'

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

  describe 'Internal server error (500)' do
    context 'GET /500' do
      it 'returns the internal server error page' do
        get '/500'

        expect(response).to have_http_status(:internal_server_error)
        expect(response.header['Content-Type']).to include 'text/html'
        expect(response.body).to include(t('page_titles.internal_server_error'))
      end
    end
  end
end
