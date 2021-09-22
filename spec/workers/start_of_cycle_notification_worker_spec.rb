require 'rails_helper'

RSpec.describe StartOfCycleNotificationWorker do
  describe '#perform' do
    let(:providers_needing_set_up) { create_list(:provider, 2, :with_signed_agreement) }
    let(:provider_users_who_need_to_set_up_permissions) do
      create_list(:provider_user, 2, providers: providers_needing_set_up)
    end
    let(:provider_with_chaser_sent) { create(:provider, :with_signed_agreement) }

    let(:other_providers) { create_list(:provider, 2, :with_signed_agreement) }
    let(:other_provider_users) { create_list(:provider_user, 2, providers: other_providers) }
    let(:user_who_has_received_mail) do
      user = create(:provider_user, providers: providers_needing_set_up)
      user.provider_permissions.update_all(manage_organisations: true)
      user
    end

    let!(:delivered_email) do
      create(
        :chaser_sent,
        chased: user_who_has_received_mail,
        chaser_type: "#{service}_service_is_now_open",
      )
      create(
        :chaser_sent,
        chased: user_who_has_received_mail,
        chaser_type: 'set_up_organisation_permissions',
      )
    end

    before do
      allow(ProviderMailer).to receive(:apply_service_is_now_open)
      allow(ProviderMailer).to receive(:find_service_is_now_open)
      allow(ProviderMailer).to receive(:set_up_organisation_permissions)
      provider_users_who_need_to_set_up_permissions.map { |user| user.provider_permissions.update_all(manage_organisations: true) }
      other_provider_users.map { |user| user.provider_permissions.update_all(manage_organisations: true) }
      providers_needing_set_up.each { |provider| create(:provider_relationship_permissions, :not_set_up_yet, training_provider: provider) }
    end

    context 'when the specified service is :find' do
      let(:service) { :find }

      it 'notifies all provider users that the service is open' do
        described_class.new.perform(service)

        expect(ProviderMailer).to have_received(:find_service_is_now_open).with(provider_users_who_need_to_set_up_permissions.first)
        expect(ProviderMailer).to have_received(:find_service_is_now_open).with(provider_users_who_need_to_set_up_permissions.last)
        expect(ProviderMailer).to have_received(:find_service_is_now_open).with(other_provider_users.first)
        expect(ProviderMailer).to have_received(:find_service_is_now_open).with(other_provider_users.last)
        expect(ProviderMailer).not_to have_received(:find_service_is_now_open).with(user_who_has_received_mail)
      end

      it 'notifies provider users who need to set up permissions for their organisation' do
        allow(ProviderSetup).to receive(:new).and_return(instance_double(ProviderSetup, relationships_pending: [1]))
        described_class.new.perform(service)

        expect(ProviderMailer).to have_received(:set_up_organisation_permissions).with(provider_users_who_need_to_set_up_permissions.first)
        expect(ProviderMailer).to have_received(:set_up_organisation_permissions).with(provider_users_who_need_to_set_up_permissions.last)
        expect(ProviderMailer).not_to have_received(:set_up_organisation_permissions).with(user_who_has_received_mail)
      end

      it 'omits managing users with no relationships to set up' do
        allow(ProviderSetup).to receive(:new).and_return(instance_double(ProviderSetup, relationships_pending: []))
        described_class.new.perform(service)

        expect(ProviderMailer).not_to have_received(:set_up_organisation_permissions).with(provider_users_who_need_to_set_up_permissions.first)
        expect(ProviderMailer).not_to have_received(:set_up_organisation_permissions).with(provider_users_who_need_to_set_up_permissions.last)
      end

      it 'ignores providers with chasers sent' do
        create(:chaser_sent, chased: provider_with_chaser_sent, chaser_type: "#{service}_service_open_organisation_notification")

        expect { described_class.new.perform(service) }.not_to change(ChaserSent.where(chased: provider_with_chaser_sent), :count)
      end

      context 'when the mailer raises an error' do
        before { allow(ProviderMailer).to receive(:find_service_is_now_open).and_raise('badness') }

        it 'does not create chaser sent records' do
          expect { described_class.new.perform(service) }.to raise_error('badness')

          expect(ChaserSent.where(chased: providers_needing_set_up)).to be_empty
          expect(ChaserSent.where(chased: provider_users_who_need_to_set_up_permissions + other_provider_users)).to be_empty
          expect(ProviderMailer).not_to have_received(:set_up_organisation_permissions).with(provider_users_who_need_to_set_up_permissions.first)
          expect(ProviderMailer).not_to have_received(:set_up_organisation_permissions).with(provider_users_who_need_to_set_up_permissions.last)
        end
      end
    end

    context 'when the specified service is :apply' do
      let(:service) { :apply }

      it 'notifies all provider users' do
        described_class.new.perform(service)

        expect(ProviderMailer).to have_received(:apply_service_is_now_open).with(provider_users_who_need_to_set_up_permissions.first)
        expect(ProviderMailer).to have_received(:apply_service_is_now_open).with(provider_users_who_need_to_set_up_permissions.last)
        expect(ProviderMailer).to have_received(:apply_service_is_now_open).with(other_provider_users.first)
        expect(ProviderMailer).to have_received(:apply_service_is_now_open).with(other_provider_users.last)
        expect(ProviderMailer).not_to have_received(:apply_service_is_now_open).with(user_who_has_received_mail)
      end

      it 'ignores providers with chasers sent' do
        create(:chaser_sent, chased: provider_with_chaser_sent, chaser_type: "#{service}_service_open_organisation_notification")

        expect { described_class.new.perform(service) }.not_to change(ChaserSent.where(chased: provider_with_chaser_sent), :count)
      end
    end
  end
end
