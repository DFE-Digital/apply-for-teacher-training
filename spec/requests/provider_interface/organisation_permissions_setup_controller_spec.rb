require 'rails_helper'

RSpec.describe ProviderInterface::OrganisationPermissionsSetupController do
  include DfESignInHelpers

  let(:provider) { create(:provider) }
  let(:provider_user) { create(:provider_user, :with_dfe_sign_in, :with_manage_organisations, providers: [provider]) }

  before do
    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
    get auth_dfe_callback_path
  end

  context 'when there are permissions requiring setup' do
    let(:ratifying_provider) { create(:provider) }
    let!(:course) { create(:course, :open, accredited_provider: ratifying_provider, provider:) }
    let(:store) { instance_double(WizardStateStores::RedisStore) }
    let(:wizard_store_value) { { 'relationship_ids' => [permissions.id] }.to_json }
    let!(:permissions) do
      create(
        :provider_relationship_permissions,
        :not_set_up_yet,
        ratifying_provider:,
        training_provider: provider,
      )
    end

    before do
      allow(store).to receive(:read).and_return(wizard_store_value)
      allow(store).to receive(:write)
      allow(store).to receive(:delete)
      allow(WizardStateStores::RedisStore).to receive(:new).and_return(store)
    end

    it 'returns a 200 on the setup index page' do
      get provider_interface_organisation_permissions_setup_index_path

      expect(store).to have_received(:delete)
      expect(response).to have_http_status(:ok)
    end

    it 'tracks validation errors on update' do
      expect {
        patch(
          provider_interface_organisation_permissions_setup_path(permissions),
          params: {
            id: permissions.id,
            provider_relationship_permissions: {},
          },
        )
      }.to change(ValidationError, :count).by(1)
    end

    context 'when the wizard state store has not been set up' do
      let(:wizard_store_value) { nil }

      it 'redirects edit to the index action' do
        get edit_provider_interface_organisation_permissions_setup_path(permissions)

        expect(response).to have_http_status(:found)
        expect(response.redirect_url).to eq(provider_interface_organisation_permissions_setup_index_url)
      end

      it 'redirects update to the index action' do
        patch provider_interface_organisation_permissions_setup_path(permissions), params: {}

        expect(response).to have_http_status(:found)
        expect(response.redirect_url).to eq(provider_interface_organisation_permissions_setup_index_url)
      end

      it 'redirects check to the index action' do
        get check_provider_interface_organisation_permissions_setup_index_path

        expect(response).to have_http_status(:found)
        expect(response.redirect_url).to eq(provider_interface_organisation_permissions_setup_index_url)
      end

      it 'redirects commit to the index action' do
        patch commit_provider_interface_organisation_permissions_setup_index_path

        expect(response).to have_http_status(:found)
        expect(response.redirect_url).to eq(provider_interface_organisation_permissions_setup_index_url)
      end
    end
  end

  context 'when there are no permissions requiring setup' do
    let(:ratifying_provider) { create(:provider) }
    let!(:course) { create(:course, :open, accredited_provider: ratifying_provider, provider:) }
    let!(:permissions) do
      create(
        :provider_relationship_permissions,
        ratifying_provider:,
        training_provider: provider,
      )
    end

    before do
      allow(Sentry).to receive(:capture_exception)
    end

    it 'redirects edit to the applications page' do
      get provider_interface_organisation_permissions_setup_index_path

      expect(Sentry).to have_received(:capture_exception)
      expect(response).to have_http_status(:found)
      expect(response.redirect_url).to eq(provider_interface_applications_url)
    end
  end
end
