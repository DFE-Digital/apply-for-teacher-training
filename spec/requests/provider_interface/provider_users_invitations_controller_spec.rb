require 'rails_helper'

RSpec.describe ProviderInterface::ProviderUsersInvitationsController, type: :request do
  include DfESignInHelpers
  include ModelWithErrorsStubHelper

  describe 'validation errors' do
    let(:provider) { create(:provider, :with_signed_agreement) }
    let(:managing_user) { create(:provider_user, :with_manage_users, providers: [provider]) }

    before do
      allow(DfESignInUser).to receive(:load_from_session).and_return(managing_user)

      user_exists_in_dfe_sign_in(email_address: managing_user.email_address)
    end

    it 'tracks validation errors on POST to update_details' do
      expect {
        post provider_interface_update_invitation_basic_details_path,
             params: { provider_interface_provider_user_invitation_wizard: { first_name: '' } }
      }.to change(ValidationError, :count).by(1)
    end

    it 'tracks validation errors on POST to update_providers' do
      expect {
        post provider_interface_update_invitation_providers_path,
             params: { provider_interface_provider_user_invitation_wizard: { providers: [] } }
      }.to change(ValidationError, :count).by(1)
    end

    it 'tracks validation errors on POST to update_permissions' do
      stub_model_instance_with_errors(
        ProviderInterface::ProviderUserInvitationWizard,
        valid_for_current_step?: false, previous_step: :details, first_name: nil, last_name: nil,
        permissions_form: instance_double(
          ProviderInterface::FieldsForProviderUserPermissionsForm,
          id: '1', provider_id: provider.id, view_applications_only: nil, permissions: {},
        )
      )

      expect {
        post provider_interface_update_invitation_provider_permissions_path(provider),
             params: { provider_interface_provider_user_invitation_wizard: { provider_permissions: { provider.id => { view_applications_only: 'false' } } } }
      }.to change(ValidationError, :count).by(1)
    end

    it 'tracks validation errors on POST to commit' do
      allow(SaveAndInviteProviderUser).to receive(:new).and_return(instance_double(SaveAndInviteProviderUser, call: false))

      expect { post provider_interface_commit_invitation_path }.to change(ValidationError, :count).by(1)
    end
  end
end
