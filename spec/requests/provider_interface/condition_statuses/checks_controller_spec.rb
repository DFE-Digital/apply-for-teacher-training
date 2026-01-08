require 'rails_helper'

RSpec.describe ProviderInterface::ConditionStatuses::ChecksController do
  include DfESignInHelpers
  include ModelWithErrorsStubHelper

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in, :with_make_decisions) }
  let(:provider) { provider_user.providers.first }
  let(:application_form) { build(:application_form, :minimum_info) }
  let(:course) { build(:course, :open, provider:) }
  let(:course_option) { build(:course_option, course:) }

  before do
    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
    get auth_dfe_callback_path
  end

  describe 'if application choice is in a recruited state' do
    let!(:application_choice) do
      create(:application_choice, :recruited,
             application_form:,
             course_option:)
    end
    let(:referer) { "http://www.example.com/provider/applications/#{application_choice.id}" }

    context 'PUT update' do
      it 'redirects back' do
        put(
          provider_interface_condition_statuses_check_path(application_choice),
          params: {},
          headers: { 'HTTP_REFERER' => referer },
        )

        expect(response).to have_http_status(:found)
        expect(response.redirect_url).to eq(referer)
      end
    end
  end

  describe 'validation errors' do
    let!(:application_choice) do
      create(:application_choice, :accepted,
             application_form:,
             course_option:)
    end

    it 'tracks errors on update' do
      condition_id = application_choice.offer.conditions.first.id.to_s
      expect {
        put(
          provider_interface_condition_statuses_check_path(application_choice),
          params: { provider_interface_confirm_conditions_wizard: { statuses: { condition_id => { test: :test } } } },
        )
      }.to change(ValidationError, :count).by(1)
    end
  end
end
