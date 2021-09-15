require 'rails_helper'

RSpec.describe StartOfCycleNotificationWorker do
  describe '#perform' do
    let(:providers_needing_set_up) { create_list(:provider, 2, :with_signed_agreement) }
    let(:provider_users_who_need_to_set_up_permissions) do
      create_list(:provider_user, 2, providers: providers_needing_set_up)
    end

    let(:other_providers) { create_list(:provider, 2, :with_signed_agreement) }
    let(:other_provider_users) { create_list(:provider_user, 2, providers: other_providers) }

    before do
      allow(ProviderMailer).to receive(:apply_service_is_now_open)
      allow(ProviderMailer).to receive(:find_service_is_now_open)
      provider_users_who_need_to_set_up_permissions.map { |user| user.provider_permissions.update_all(manage_organisations: true) }
      other_provider_users.map { |user| user.provider_permissions.update_all(manage_organisations: true) }
    end

    context 'when the specified service is :apply' do
      it 'notifies provider users who need to set up permissions for their organisation' do
        # A provider user without manage organisation permissions
        create(:provider_user, providers: providers_needing_set_up)

        Timecop.freeze(2021, 10, 12, 10, 0) do
          described_class.new.perform(:apply)

          expect(ProviderMailer).to have_received(:apply_service_is_now_open).with(provider_users_who_need_to_set_up_permissions.first)
          expect(ProviderMailer).to have_received(:apply_service_is_now_open).with(provider_users_who_need_to_set_up_permissions.last)
        end
      end
    end

    context 'when the specified service is :find' do
      it 'notifies all provider users' do
        Timecop.freeze(2021, 10, 5, 10, 0) do
          described_class.new.perform(:find)

          expect(ProviderMailer).to have_received(:find_service_is_now_open).with(provider_users_who_need_to_set_up_permissions.first)
          expect(ProviderMailer).to have_received(:find_service_is_now_open).with(provider_users_who_need_to_set_up_permissions.last)
          expect(ProviderMailer).to have_received(:find_service_is_now_open).with(other_provider_users.first)
          expect(ProviderMailer).to have_received(:find_service_is_now_open).with(other_provider_users.last)
        end
      end
    end
  end
end
