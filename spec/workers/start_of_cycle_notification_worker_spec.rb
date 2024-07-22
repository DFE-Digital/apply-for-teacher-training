require 'rails_helper'

RSpec.describe StartOfCycleNotificationWorker do
  describe '#perform' do
    let(:mailer_delivery) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }
    let(:providers_needing_set_up) { %w[AAA BBB].map { |name| create(:provider, :no_users, name:) } }
    let(:provider_users_who_need_to_set_up_permissions) do
      create_list(:provider_user, 2, providers: providers_needing_set_up)
    end

    let(:other_providers) { %w[CCC DDD].map { |name| create(:provider, name:) } }
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
      allow(ProviderMailer).to receive_messages(apply_service_is_now_open: mailer_delivery, find_service_is_now_open: mailer_delivery, set_up_organisation_permissions: mailer_delivery)
      provider_users_who_need_to_set_up_permissions.map { |user| user.provider_permissions.update_all(manage_organisations: true) }
      other_provider_users.map { |user| user.provider_permissions.update_all(manage_organisations: true) }
      providers_needing_set_up.each { |provider| create(:provider_relationship_permissions, :not_set_up_yet, training_provider: provider) }
    end

    context 'when the specified service is find' do
      let(:service) { 'find' }

      before do
        TestSuiteTimeMachine.travel_permanently_to(CycleTimetable.find_opens.change(hour: 16))
      end

      it 'notifies all provider users that the service is open' do
        described_class.new.perform(service)

        expect(ProviderMailer).to have_received(:find_service_is_now_open).with(provider_users_who_need_to_set_up_permissions.first)
        expect(ProviderMailer).to have_received(:find_service_is_now_open).with(provider_users_who_need_to_set_up_permissions.last)
        expect(ProviderMailer).to have_received(:find_service_is_now_open).with(other_provider_users.first)
        expect(ProviderMailer).to have_received(:find_service_is_now_open).with(other_provider_users.last)
        expect(ProviderMailer).not_to have_received(:find_service_is_now_open).with(user_who_has_received_mail)
      end

      it 'notifies provider users who need to set up permissions for their organisation' do
        ratifying_provider = create(:provider, name: 'QQQ')
        another_provider = create(:provider, name: 'RRR')
        relationship1 = create(:provider_relationship_permissions,
                               :not_set_up_yet,
                               training_provider: providers_needing_set_up.first,
                               ratifying_provider:)
        relationship2 = create(:provider_relationship_permissions,
                               :not_set_up_yet,
                               training_provider: another_provider,
                               ratifying_provider: providers_needing_set_up.last)
        relationship3 = create(:provider_relationship_permissions,
                               :not_set_up_yet,
                               training_provider: providers_needing_set_up.first,
                               ratifying_provider: other_providers.first)
        allow(ProviderSetup).to receive(:new).and_return(instance_double(ProviderSetup, relationships_pending: [relationship2, relationship1, relationship3]))

        described_class.new.perform(service)

        expected_relationships = {
          providers_needing_set_up.first.name => [other_providers.first.name, ratifying_provider.name],
          providers_needing_set_up.last.name => [another_provider.name],
        }

        expect(ProviderMailer).to have_received(:set_up_organisation_permissions).with(provider_users_who_need_to_set_up_permissions.first, expected_relationships)
        expect(ProviderMailer).to have_received(:set_up_organisation_permissions).with(provider_users_who_need_to_set_up_permissions.last, expected_relationships)
        expect(ProviderMailer).not_to have_received(:set_up_organisation_permissions).with(user_who_has_received_mail)
      end

      it 'omits managing users with no relationships to set up' do
        allow(ProviderSetup).to receive(:new).and_return(instance_double(ProviderSetup, relationships_pending: []))
        described_class.new.perform(service)

        expect(ProviderMailer).not_to have_received(:set_up_organisation_permissions)
      end

      it 'ignores providers with chasers sent' do
        provider_with_chaser_sent = create(:provider)
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

      context 'when a user has yet to receive the setup permissions email but has received the service open mail' do
        it 'sends the setup permissions email only' do
          ratifying_provider = create(:provider, name: 'QQQ')
          relationship = create(:provider_relationship_permissions,
                                :not_set_up_yet,
                                training_provider: providers_needing_set_up.first,
                                ratifying_provider:)
          create(:chaser_sent, chased: provider_users_who_need_to_set_up_permissions.first, chaser_type: 'find_service_is_now_open')
          allow(ProviderSetup).to receive(:new).and_return(instance_double(ProviderSetup, relationships_pending: [relationship]))

          described_class.new.perform(service)

          expected_relationships = { providers_needing_set_up.first.name => [ratifying_provider.name] }

          expect(ProviderMailer).not_to have_received(:find_service_is_now_open).with(provider_users_who_need_to_set_up_permissions.first)
          expect(ProviderMailer).to have_received(:set_up_organisation_permissions).with(provider_users_who_need_to_set_up_permissions.first, expected_relationships)

          expect(ProviderMailer).to have_received(:find_service_is_now_open).with(provider_users_who_need_to_set_up_permissions.last)
          expect(ProviderMailer).to have_received(:set_up_organisation_permissions).with(provider_users_who_need_to_set_up_permissions.last, expected_relationships)
        end
      end

      context 'when a provider user received an email last year' do
        it 'they also receive one the following year' do
          allow(CycleTimetable).to receive(:service_opens_today?).and_return(true)

          TestSuiteTimeMachine.travel_permanently_to(CycleTimetable.find_opens(2022).change(hour: 16))
          described_class.new.perform(service)

          TestSuiteTimeMachine.travel_permanently_to(CycleTimetable.find_opens(2023).change(hour: 16))
          described_class.new.perform(service)

          expect(ProviderMailer).to have_received(:find_service_is_now_open).with(other_provider_users.first).twice
        end
      end
    end
  end
end
