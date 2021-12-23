require 'rails_helper'

RSpec.describe SaveProviderUser do
  let(:provider) { create(:provider) }
  let(:another_provider) { create(:provider) }
  let(:new_provider) { create(:provider) }
  let(:current_provider_user) { create(:provider_user, create_notification_preference: false) }
  let(:provider_user) { create(:provider_user, create_notification_preference: false, providers: [provider, another_provider]) }
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
      described_class.new(provider_user: provider_user,
                          provider_permissions: provider_permissions)
    end

    it 'saves the provider user' do
      allow(provider_user).to receive(:save!)

      service.call!

      expect(provider_user).to have_received(:save!)
    end

    it 'adds and updates ProviderPermissions records' do
      expect { service.call! }.to change(ProviderPermissions, :count).by(3)
    end

    it 'adds and updates permissions for the saved user' do
      result = service.call!

      expect(result.provider_permissions).to include(provider_permissions.first)
      expect(result.provider_permissions).to include(provider_permissions.last)
    end

    it 'adds permissions flags for the saved user' do
      result = service.call!

      expect(result.authorisation.providers_that_actor_can_manage_users_for).to eq([another_provider])
    end

    context 'when permissions are setup' do
      let(:mailer_delivery) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }
      let(:provider_permissions) do
        [ProviderPermissions.new(provider: new_provider, provider_user: provider_user, manage_users: true)]
      end

      it 'sends a permissions granted' do
        allow(ProviderMailer).to receive(:permissions_granted).and_return(mailer_delivery)

        service.call!

        expect(ProviderMailer).to have_received(:permissions_granted)
      end
    end

    context 'when permissions are updated' do
      let(:mailer_delivery) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

      it 'sends a permissions updated email' do
        allow(ProviderMailer).to receive(:permissions_updated).and_return(mailer_delivery)

        service.call!

        expect(ProviderMailer).to have_received(:permissions_updated)
      end
    end

    it 'adds the notification preferences record to a ProviderUser' do
      expect { service.call! }.to change(ProviderUserNotificationPreferences, :count).by(1)
    end
  end
end
