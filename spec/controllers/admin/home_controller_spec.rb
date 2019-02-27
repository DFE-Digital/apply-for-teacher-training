require 'rails_helper'

RSpec.describe Admin::HomeController, type: :controller do
  describe "GET #index" do
    context "when signed in" do
      let(:user) { Admin::User.create(email: 'example@example.com', password: 'testing123', password_confirmation: 'testing123') }

      before { sign_in user }

      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context "when not signed in" do
      it "should redirect to sign in page" do
        get :index
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end
end
