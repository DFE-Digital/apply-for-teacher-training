require 'rails_helper'

RSpec.describe SaveProviderUser do
  let(:provider) { create(:provider) }
  let(:another_provider) { create(:provider) }
  let(:new_provider) { create(:provider) }
  let(:provider_user) { create(:provider_user, providers: [provider, another_provider]) }
  let(:provider_ids) { { selected: [another_provider.id], deselected: [provider.id] } }
  let(:deselected_provider_permissions) { provider_user.provider_permissions.where(provider: provider) }
  let(:provider_permissions) do
    updated_provider_permissions = provider_user.provider_permissions.find_by(provider: another_provider)
    updated_provider_permissions.manage_users = true

    [
      ProviderPermissions.new(provider: new_provider, provider_user: provider_user),
      updated_provider_permissions,
    ]
  end

  describe '#initialize' do
    it 'requires a provider_user:' do
      expect { described_class.new }.to raise_error(ArgumentError)
      expect { described_class.new(provider_user: ProviderUser.new) }.not_to raise_error
    end
  end

  describe '#call!' do
    subject(:service) do
      described_class.new(
        provider_user: provider_user,
        provider_permissions: provider_permissions,
        deselected_provider_permissions: deselected_provider_permissions,
      )
    end

    it 'saves the provider user' do
      allow(provider_user).to receive(:save!)

      service.call!

      expect(provider_user).to have_received(:save!)
    end

    it 'adds and updates ProviderPermissions records' do
      expect { service.call! }.to change(ProviderPermissions, :count).by(2)
    end

    it 'adds and updates permissions for the saved user' do
      result = service.call!

      expect(result.provider_permissions).to include(provider_permissions.first)
      expect(result.provider_permissions).to include(provider_permissions.last)
    end

    it 'removes deselected provider permissions' do
      result = service.call!

      expect(result.provider_permissions).not_to include(deselected_provider_permissions.first)
    end

    it 'adds permissions flags for the saved user' do
      result = service.call!

      expect(result.authorisation.providers_that_actor_can_manage_users_for).to eq([another_provider])
    end

    it 'adds the notification preferences record to a ProviderUser' do
      expect { service.call! }.to change(ProviderUserNotificationPreferences, :count).by(1)
    end
  end
end
