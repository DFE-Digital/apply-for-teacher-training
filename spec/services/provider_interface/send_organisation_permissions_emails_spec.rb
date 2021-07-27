require 'rails_helper'

RSpec.describe ProviderInterface::SendOrganisationPermissionsEmails do
  describe '#call' do
    let(:training_provider) { create(:provider, :with_signed_agreement) }
    let(:ratifying_provider) { create(:provider, :with_signed_agreement) }
    let!(:training_provider_users) { create_list(:provider_user, 3, providers: [training_provider]) }
    let!(:ratifying_provider_users) { create_list(:provider_user, 3, providers: [ratifying_provider]) }
    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

    subject(:service) { described_class.new(provider_user: provider_user, permissions: permissions, set_up: set_up) }

    before do
      allow(ProviderMailer).to receive(:organisation_permissions_set_up).and_return(message_delivery)
      allow(ProviderMailer).to receive(:organisation_permissions_updated).and_return(message_delivery)
      training_provider_users.first.provider_permissions.update_all(manage_organisations: true)
      training_provider_users.last.provider_permissions.update_all(manage_organisations: true)
      ratifying_provider_users.first.provider_permissions.update_all(manage_organisations: true)
      ratifying_provider_users.last.provider_permissions.update_all(manage_organisations: true)
    end

    context 'when permissions have not been set up' do
      let(:set_up) { true }
      let(:permissions) do
        create(:provider_relationship_permissions, :not_set_up_yet, training_provider: training_provider, ratifying_provider: ratifying_provider)
      end

      context 'when the user is setting up permissions on behalf of the training provider' do
        let(:provider_user) { training_provider_users.last }

        it 'sends a set up email to users for the ratifying provider' do
          service.call

          expect(ProviderMailer).to have_received(:organisation_permissions_set_up).with(ratifying_provider_users.first, permissions)
          expect(ProviderMailer).not_to have_received(:organisation_permissions_set_up).with(ratifying_provider_users.second, permissions)
          expect(ProviderMailer).to have_received(:organisation_permissions_set_up).with(ratifying_provider_users.last, permissions)
        end
      end

      context 'when the user is setting up permissions on behalf of the ratifying provider' do
        let(:provider_user) { ratifying_provider_users.last }

        it 'sends a set up email to users for the training provider' do
          service.call

          expect(ProviderMailer).to have_received(:organisation_permissions_set_up).with(training_provider_users.first, permissions)
          expect(ProviderMailer).not_to have_received(:organisation_permissions_set_up).with(training_provider_users.second, permissions)
          expect(ProviderMailer).to have_received(:organisation_permissions_set_up).with(training_provider_users.last, permissions)
        end
      end
    end

    context 'when permissions have already been set up' do
      let(:set_up) { false }
      let(:permissions) do
        create(:provider_relationship_permissions, training_provider: training_provider, ratifying_provider: ratifying_provider)
      end

      context 'when the user is making changes on behalf of the training provider' do
        let(:provider_user) { training_provider_users.last }

        it 'sends an update email to the users for the ratifying provider' do
          service.call

          expect(ProviderMailer).to have_received(:organisation_permissions_updated).with(ratifying_provider_users.first, permissions)
          expect(ProviderMailer).not_to have_received(:organisation_permissions_updated).with(ratifying_provider_users.second, permissions)
          expect(ProviderMailer).to have_received(:organisation_permissions_updated).with(ratifying_provider_users.last, permissions)
        end
      end

      context 'when the user is making changes on behalf of the ratifying provider' do
        let(:provider_user) { ratifying_provider_users.last }

        it 'sends an update email to the users for the training provider' do
          service.call

          expect(ProviderMailer).to have_received(:organisation_permissions_updated).with(training_provider_users.first, permissions)
          expect(ProviderMailer).not_to have_received(:organisation_permissions_updated).with(training_provider_users.second, permissions)
          expect(ProviderMailer).to have_received(:organisation_permissions_updated).with(training_provider_users.last, permissions)
        end
      end
    end
  end
end
