require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe 'GET #landing' do
    context 'when not signed in' do
      it 'returns http success' do
        get :landing
        expect(response).to have_http_status(:success)
      end
    end

    context 'when signed in' do
      let(:candidate) { create(:candidate) }
      before { sign_in candidate }

      it 'redirects to index / authenticated root' do
        get :landing
        expect(response).to redirect_to(authenticated_root_path)
      end
    end
  end

  describe 'GET #index' do
    context 'when signed in' do
      let(:candidate) { create(:candidate) }
      before { sign_in candidate }

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context 'when not signed in' do
      it 'redirects to landing page / unauthenticated root' do
        get :index
        expect(response).to redirect_to(unauthenticated_root_path)
      end
    end
  end
end
