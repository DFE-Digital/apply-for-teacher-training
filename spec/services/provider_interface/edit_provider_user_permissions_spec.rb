require 'rails_helper'

RSpec.describe ProviderInterface::EditProviderUserPermissions do
  let(:mailer_delivery) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }
  let(:provider_user) { create(:provider_user, :with_provider) }
  let(:provider) { provider_user.providers.first }
  let(:permissions) { %w[make_decisions view_safeguarding_information view_diversity_information] }
  let(:updated_permissions) { %w[make_decisions view_safeguarding_information] }
  let(:actor) { create(:provider_user) }
  let(:service) do
    described_class.new(actor:,
                        provider:,
                        provider_user:,
                        permissions: updated_permissions)
  end

  before do
    provider_permissions = provider_user.provider_permissions.find_by(provider:)
    ProviderPermissions::VALID_PERMISSIONS.each do |permission|
      provider_permissions.send("#{permission}=", permissions.include?(permission.to_s))
    end
    provider_permissions.save!
  end

  describe '#initialize' do
    it 'guards against nil permissions' do
      instance = described_class.new(actor:, provider:, provider_user:, permissions: nil)

      expect(instance.permissions).to eq([])
    end
  end

  describe '#save' do
    context 'when the actor does not have the manage users permission' do
      it 'raises an access denied error' do
        expect { service.save }.to raise_error(ProviderInterface::AccessDenied)
      end
    end

    context 'when the actor can manage users for the given provider' do
      let(:actor) { create(:provider_user, :with_manage_users, providers: [provider]) }

      it 'updates the relationship between user and provider' do
        service.save

        provider_permissions = provider_user.provider_permissions.find_by(provider:)
        expect(provider_permissions.view_diversity_information).to be false
        expect(provider_permissions.make_decisions).to be true
        expect(provider_permissions.view_safeguarding_information).to be true
      end

      it 'audits the change', :with_audited do
        expect { service.save }.to change(provider_user.associated_audits, :count).by(1)
        expect(provider_user.associated_audits.last.audited_changes).to eq({ 'view_diversity_information' => [true, false] })
      end

      it 'sends a permissions updated email to the user' do
        allow(ProviderMailer).to receive(:permissions_updated).and_return(mailer_delivery)

        service.save

        expect(ProviderMailer).to have_received(:permissions_updated).with(provider_user, provider, updated_permissions, actor)
      end
    end
  end
end
