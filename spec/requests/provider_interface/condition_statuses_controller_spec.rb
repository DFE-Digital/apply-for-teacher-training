require 'rails_helper'

RSpec.describe ProviderInterface::ConditionStatusesController, type: :request do
  include DfESignInHelpers
  include ModelWithErrorsStubHelper

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in, :with_make_decisions) }
  let(:provider) { provider_user.providers.first }
  let(:application_form) { build(:application_form, :minimum_info) }
  let(:course) { build(:course, :open_on_apply, provider: provider) }
  let(:course_option) { build(:course_option, course: course) }

  before do
    allow(ProviderUser).to receive(:load_from_session).and_return(provider_user)
  end

  describe 'if application choice is in a recruited state' do
    let!(:application_choice) do
      create(:application_choice, :recruited,
             application_form: application_form,
             course_option: course_option)
    end
    let(:referer) { "http://www.example.com/provider/applications/#{application_choice.id}" }

    context 'GET edit' do
      it 'redirects back' do
        get(
          edit_provider_interface_condition_statuses_path(application_choice),
          params: nil,
          headers: { 'HTTP_REFERER' => referer },
        )

        expect(response.status).to eq(302)
        expect(response.redirect_url).to eq(referer)
      end
    end

    context 'PATCH confirm_update' do
      it 'redirects back' do
        patch(
          confirm_provider_interface_condition_statuses_path(application_choice),
          params: {},
          headers: { 'HTTP_REFERER' => referer },
        )

        expect(response.status).to eq(302)
        expect(response.redirect_url).to eq(referer)
      end
    end

    context 'PATCH update' do
      it 'redirects back' do
        patch(
          provider_interface_condition_statuses_path(application_choice),
          params: {},
          headers: { 'HTTP_REFERER' => referer },
        )

        expect(response.status).to eq(302)
        expect(response.redirect_url).to eq(referer)
      end
    end
  end

  describe 'validation errors' do
    let!(:application_choice) do
      create(:application_choice, :with_accepted_offer,
             application_form: application_form,
             course_option: course_option)
    end

    it 'tracks errors on confirm_update' do
      condition_id = application_choice.offer.conditions.first.id.to_s
      expect {
        patch(
          confirm_provider_interface_condition_statuses_path(application_choice),
          params: { provider_interface_confirm_conditions_wizard: { statuses: { condition_id => { test: :test } } } },
        )
      }.to change(ValidationError, :count).by(1)
    end

    it 'tracks errors on update' do
      stub_model_instance_with_errors(ProviderInterface::ConfirmConditionsWizard, { valid?: false })

      expect {
        patch(
          provider_interface_condition_statuses_path(application_choice),
          params: {},
        )
      }.to change(ValidationError, :count).by(1)
    end
  end
end
