require 'rails_helper'

RSpec.describe SaveProviderUser do
  let(:provider) { create(:provider) }
  let(:new_provider_user_from_form) {
    SupportInterface::ProviderUserForm.new(
      email_address: 'test+invite_provider_user@example.com',
      first_name: 'Firstname',
      last_name: 'Lastname',
      provider_ids: [provider.id],
    ).build
  }
  let(:permissions) { { manage_users: [provider.id] } }

  describe '#initialize' do
    it 'requires a provider_user:' do
      expect { described_class.new }.to raise_error(ArgumentError)
      expect { described_class.new(provider_user: ProviderUser.new) }.not_to raise_error
    end
  end

  describe '#call!' do
    subject(:service) do
      described_class.new(provider_user: new_provider_user_from_form, permissions: permissions)
    end

    it 'saves the provider user' do
      expect { service.call! }.to change(ProviderUser, :count).by(1)
    end

    it 'updates permissions for the saved user' do
      expect { @provider_user = service.call! }.to change(ProviderPermissions, :count).by(1)

      expected_permissions = ProviderPermissions.where(
        provider: provider,
        provider_user: @provider_user,
        manage_users: true,
      )

      expect(expected_permissions.count).to eq(1)
    end
  end
end
