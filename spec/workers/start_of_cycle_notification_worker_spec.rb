require 'rails_helper'

RSpec.describe StartOfCycleNotificationWorker do
  describe '#perform' do
    let(:providers_needing_set_up) { create_list(:provider, 2, :with_signed_agreement) }
    let(:provider_users_who_need_to_set_up_permissions) do
      create_list(:provider_user, 2, providers: providers_needing_set_up)
    end

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

      it 'notifies provider users who need to set up permissions for their organisation' do
        # A provider user without manage organisation permissions
        create(:provider_user, providers: providers_needing_set_up)

        Timecop.freeze(2021, 10, 12, 9, 1) do
          described_class.new.perform(service)

          expect(ProviderMailer).to have_received(:find_service_is_now_open).with(provider_users_who_need_to_set_up_permissions.first)
          expect(ProviderMailer).to have_received(:find_service_is_now_open).with(provider_users_who_need_to_set_up_permissions.last)
          expect(ProviderMailer).to have_received(:find_service_is_now_open).with(other_provider_users.first)
          expect(ProviderMailer).to have_received(:find_service_is_now_open).with(other_provider_users.last)
          expect(ProviderMailer).not_to have_received(:find_service_is_now_open).with(user_who_has_received_mail)

          expect(ProviderMailer).to have_received(:set_up_organisation_permissions).with(provider_users_who_need_to_set_up_permissions.first)
          expect(ProviderMailer).to have_received(:set_up_organisation_permissions).with(provider_users_who_need_to_set_up_permissions.last)
          expect(ProviderMailer).not_to have_received(:set_up_organisation_permissions).with(user_who_has_received_mail)
        end
      end
    end

    context 'when the specified service is :apply' do
      let(:service) { :apply }

      it 'notifies all provider users' do
        Timecop.freeze(2021, 10, 12, 9, 1) do
          described_class.new.perform(service)

          expect(ProviderMailer).to have_received(:apply_service_is_now_open).with(provider_users_who_need_to_set_up_permissions.first)
          expect(ProviderMailer).to have_received(:apply_service_is_now_open).with(provider_users_who_need_to_set_up_permissions.last)
          expect(ProviderMailer).to have_received(:apply_service_is_now_open).with(other_provider_users.first)
          expect(ProviderMailer).to have_received(:apply_service_is_now_open).with(other_provider_users.last)
          expect(ProviderMailer).not_to have_received(:apply_service_is_now_open).with(user_who_has_received_mail)
        end
      end
    end
  end
end
