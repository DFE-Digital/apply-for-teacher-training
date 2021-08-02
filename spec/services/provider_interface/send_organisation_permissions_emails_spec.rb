require 'rails_helper'

RSpec.describe ProviderInterface::SendOrganisationPermissionsEmails do
  describe '#call' do
    let(:training_provider) { create(:provider, :with_signed_agreement, name: 'University of Croydon') }
    let(:ratifying_provider) { create(:provider, :with_signed_agreement, name: 'University of Purley') }
    let!(:training_provider_users) { create_list(:provider_user, 3, providers: [training_provider]) }
    let!(:ratifying_provider_users) { create_list(:provider_user, 3, providers: [ratifying_provider]) }
    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

    subject(:service) { described_class.new(provider_user: provider_user, provider: provider, permissions: permissions) }

    before do
      allow(ProviderMailer).to receive(:organisation_permissions_set_up).and_return(message_delivery)
      allow(ProviderMailer).to receive(:organisation_permissions_updated).and_return(message_delivery)
      training_provider_users.first.provider_permissions.update_all(manage_organisations: true)
      training_provider_users.last.provider_permissions.update_all(manage_organisations: true)
      ratifying_provider_users.first.provider_permissions.update_all(manage_organisations: true)
      ratifying_provider_users.last.provider_permissions.update_all(manage_organisations: true)
    end

    context 'when permissions have not been set up' do
      let(:permissions) do
        create(:provider_relationship_permissions, :not_set_up_yet, training_provider: training_provider, ratifying_provider: ratifying_provider)
      end

      context 'when the user is setting up permissions on behalf of the training provider' do
        let(:provider) { nil }
        let(:provider_user) { training_provider_users.first }

        it 'sends a set up email to managing users for the ratifying provider' do
          service.call

          expect(ProviderMailer).to have_received(:organisation_permissions_set_up).with(ratifying_provider_users.first, ratifying_provider, permissions)
          expect(ProviderMailer).not_to have_received(:organisation_permissions_set_up).with(ratifying_provider_users.second, ratifying_provider, permissions)
          expect(ProviderMailer).to have_received(:organisation_permissions_set_up).with(ratifying_provider_users.last, ratifying_provider, permissions)
        end
      end

      context 'when the user is setting up permissions on behalf of the ratifying provider' do
        let(:provider) { nil }
        let(:provider_user) { ratifying_provider_users.first }

        it 'sends a set up email to managing users for the training provider' do
          service.call

          expect(ProviderMailer).to have_received(:organisation_permissions_set_up).with(training_provider_users.first, training_provider, permissions)
          expect(ProviderMailer).not_to have_received(:organisation_permissions_set_up).with(training_provider_users.second, training_provider, permissions)
          expect(ProviderMailer).to have_received(:organisation_permissions_set_up).with(training_provider_users.last, training_provider, permissions)
        end
      end

      context 'when the user setting up permissions belongs to both orgs in the permissions relationship' do
        let(:provider) { nil }
        let(:provider_user) { ratifying_provider_users.first }

        before do
          training_provider_users.first.providers << ratifying_provider
          training_provider_users.last.providers << ratifying_provider
          ratifying_provider_users.first.providers << training_provider
          ratifying_provider_users.last.providers << training_provider
        end

        it 'sends a set up email to managing users for alphabetically first provider' do
          service.call

          expect(ProviderMailer).to have_received(:organisation_permissions_set_up).with(training_provider_users.first, training_provider, permissions)
          expect(ProviderMailer).not_to have_received(:organisation_permissions_set_up).with(training_provider_users.second, training_provider, permissions)
          expect(ProviderMailer).to have_received(:organisation_permissions_set_up).with(training_provider_users.last, training_provider, permissions)
        end
      end
    end

    context 'when permissions have already been set up' do
      let(:permissions) do
        create(:provider_relationship_permissions, training_provider: training_provider, ratifying_provider: ratifying_provider)
      end

      context 'when the user is making changes on behalf of the training provider' do
        let(:provider) { training_provider }
        let(:provider_user) { training_provider_users.first }

        it 'sends an update email to managing users for the ratifying provider' do
          service.call

          expect(ProviderMailer).to have_received(:organisation_permissions_updated).with(ratifying_provider_users.first, ratifying_provider, permissions)
          expect(ProviderMailer).not_to have_received(:organisation_permissions_updated).with(ratifying_provider_users.second, ratifying_provider, permissions)
          expect(ProviderMailer).to have_received(:organisation_permissions_updated).with(ratifying_provider_users.last, ratifying_provider, permissions)
        end
      end

      context 'when the user is making changes on behalf of the ratifying provider' do
        let(:provider) { ratifying_provider }
        let(:provider_user) { ratifying_provider_users.first }

        it 'sends an update email to managing users for the training provider' do
          service.call

          expect(ProviderMailer).to have_received(:organisation_permissions_updated).with(training_provider_users.first, training_provider, permissions)
          expect(ProviderMailer).not_to have_received(:organisation_permissions_updated).with(training_provider_users.second, training_provider, permissions)
          expect(ProviderMailer).to have_received(:organisation_permissions_updated).with(training_provider_users.last, training_provider, permissions)
        end
      end
    end

    context 'when the user changing permissions belongs to both orgs in the permissions relationship' do
      let(:permissions) do
        create(:provider_relationship_permissions, training_provider: training_provider, ratifying_provider: ratifying_provider)
      end

      before do
        training_provider_users.first.providers << ratifying_provider
        training_provider_users.last.providers << ratifying_provider
        ratifying_provider_users.first.providers << training_provider
        ratifying_provider_users.last.providers << training_provider
      end

      context 'when the context of the change is from the training provider' do
        let(:provider) { training_provider }
        let(:provider_user) { training_provider_users.first }

        it 'sends an update email to managing users for the ratifying provider' do
          service.call

          expect(ProviderMailer).to have_received(:organisation_permissions_updated).with(ratifying_provider_users.first, ratifying_provider, permissions)
          expect(ProviderMailer).not_to have_received(:organisation_permissions_updated).with(ratifying_provider_users.second, ratifying_provider, permissions)
          expect(ProviderMailer).to have_received(:organisation_permissions_updated).with(ratifying_provider_users.last, ratifying_provider, permissions)
        end
      end

      context 'when the context of the change is from the ratifying provider' do
        let(:provider) { ratifying_provider }
        let(:provider_user) { ratifying_provider_users.first }

        it 'sends an update email to managing users for the training provider' do
          service.call

          expect(ProviderMailer).to have_received(:organisation_permissions_updated).with(training_provider_users.first, training_provider, permissions)
          expect(ProviderMailer).not_to have_received(:organisation_permissions_updated).with(training_provider_users.second, training_provider, permissions)
          expect(ProviderMailer).to have_received(:organisation_permissions_updated).with(training_provider_users.last, training_provider, permissions)
        end
      end
    end
  end
end
