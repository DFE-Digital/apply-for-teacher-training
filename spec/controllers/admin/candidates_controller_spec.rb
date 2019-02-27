require 'rails_helper'

RSpec.describe Admin::CandidatesController, type: :controller do
  context "when signed in" do
    let(:user) { Admin::User.create(email: 'example@example.com', password: 'testing123', password_confirmation: 'testing123') }

    before { sign_in user }

    describe "GET #index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET #show" do
      let(:candidate) { create(:candidate) }

      it "returns http success" do
        get :show, params: { id: candidate }
        expect(response).to have_http_status(:success)
      end
    end
  end

  context "when not signed in" do
    describe "GET #index" do
      it "redirects to admin sign in page" do
        get :index
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end

    describe "GET #show" do
      let(:candidate) { create(:candidate) }

      it "redirects to admin sign in page" do
        get :show, params: { id: candidate }
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end
end
