require 'rails_helper'

RSpec.describe SupportInterface::RemoveUserFromProvider do
  let(:mailer_delivery) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }
  let(:provider_user) { create(:provider_user, :with_provider, :with_manage_organisations) }
  let!(:provider) { provider_user.providers.first }
  let(:permissions) { provider_user.provider_permissions.first }
  let!(:service) do
    described_class.new(
      permissions_to_remove: permissions,
    )
  end

  describe '#call!' do
    it 'removes the unassociates permission from the provider user' do
      expect { service.call! }.to change(ProviderPermissions, :count).from(1).to(0)
    end

    it 'unassociates the provider user from the provider' do
      service.call!

      expect(provider_user.reload.providers).to be_empty
    end

    it 'sends an email to the provider user notifying them of the removal' do
      allow(ProviderMailer).to receive(:permissions_removed).and_return(mailer_delivery)

      service.call!

      expect(ProviderMailer).to have_received(:permissions_removed).with(provider_user, provider)
    end
  end
end
