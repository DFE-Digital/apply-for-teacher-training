require 'rails_helper'

RSpec.describe ProviderInterface::DecisionsController, type: :request do
  include DfESignInHelpers

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in, :with_make_decisions) }
  let(:provider) { provider_user.providers.first }
  let(:application_form) { build(:application_form, :minimum_info) }
  let(:course) { build(:course, :open_on_apply, provider: provider) }
  let(:course_option) { build(:course_option, course: course) }

  describe 'if application choice is not in a pending decision state' do
    let!(:application_choice) do
      create(:application_choice, :withdrawn,
             application_form: application_form,
             course_option: course_option)
    end

    before do
      user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
    end

    context 'GET new' do
      it 'responds with 302' do
        get new_provider_interface_application_choice_decision_path(application_choice)

        expect(response.status).to eq(302)
      end
    end
  end
end
