require 'rails_helper'

RSpec.describe ErrorsController, type: :controller do
  describe 'GET #not_found' do
    it 'returns not found' do
      get :not_found
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #internal_server_error' do
    it 'returns internal_server_error' do
      get :internal_server_error
      expect(response).to have_http_status(:internal_server_error)
    end
  end

  describe 'GET #forbidden' do
    it 'returns forbidden' do
      get :forbidden
      expect(response).to have_http_status(:forbidden)
    end
  end
end
