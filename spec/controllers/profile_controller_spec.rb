require 'rails_helper'

RSpec.describe ProfileController, type: :controller do
  context "when signed in" do
    let(:candidate) { create(:candidate, first_name: 'John', surname: 'Smith') }
    before { sign_in candidate }

    describe "GET #show" do
      it "returns http success" do
        get :show
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET #edit" do
      it "returns http success" do
        get :edit
        expect(response).to have_http_status(:success)
      end
    end

    describe "PATCH/PUT #update" do
      it "updates candidate" do
        put :update, params: { candidate: { first_name: 'Bob', surname: 'Jones' } }
        expect(candidate.reload.full_name).to eq('Bob Jones')
      end
    end
  end

  context "when not signed in" do
    describe "GET #show" do
      it "redirects to sign in page" do
        get :show
        expect(response).to redirect_to(new_candidate_session_path)
      end
    end

    describe "GET #edit" do
      it "redirects to sign in page" do
        get :edit
        expect(response).to redirect_to(new_candidate_session_path)
      end
    end

    describe "PATCH/PUT #update" do
      it "redirects to sign in page" do
        put :update
        expect(response).to redirect_to(new_candidate_session_path)
      end
    end
  end
end
