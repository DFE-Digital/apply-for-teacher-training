require 'rails_helper'

describe ContactDetailsController, type: :controller do
  context 'when a candidate is not signed in' do
    it 'can redirect a candidate' do
      get 'new'

      expect(response).to have_http_status(:redirect)
    end
  end
end
