require 'rails_helper'

RSpec.describe StartOfCycleNotificationWorker do
  describe '#perform' do
    let(:mailer_delivery) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }
    let(:providers_needing_set_up) { %w[AAA BBB].map { |name| create(:provider, :with_signed_agreement, name: name) } }
    let(:provider_users_who_need_to_set_up_permissions) do
      create_list(:provider_user, 2, providers: providers_needing_set_up)
    end
    let(:provider_with_chaser_sent) { create(:provider, :with_signed_agreement) }

    let(:other_providers) { %w[CCC DDD].map { |name| create(:provider, :with_signed_agreement, name: name) } }
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
      allow(ProviderMailer).to receive(:apply_service_is_now_open).and_return(mailer_delivery)
      allow(ProviderMailer).to receive(:find_service_is_now_open).and_return(mailer_delivery)
      allow(ProviderMailer).to receive(:set_up_organisation_permissions).and_return(mailer_delivery)
      provider_users_who_need_to_set_up_permissions.map { |user| user.provider_permissions.update_all(manage_organisations: true) }
      other_provider_users.map { |user| user.provider_permissions.update_all(manage_organisations: true) }
      providers_needing_set_up.each { |provider| create(:provider_relationship_permissions, :not_set_up_yet, training_provider: provider) }
    end

    context 'when the specified service is :find' do
      let(:service) { :find }

      around do |example|
        Timecop.freeze(CycleTimetable.find_opens.change(hour: 15)) do
          example.run
        end
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
        ratifying_provider = create(:provider, :with_signed_agreement, name: 'QQQ')
        another_provider = create(:provider, :with_signed_agreement, name: 'RRR')
        relationship1 = create(:provider_relationship_permissions,
                               :not_set_up_yet,
                               training_provider: providers_needing_set_up.first,
                               ratifying_provider: ratifying_provider)
        relationship2 = create(:provider_relationship_permissions,
                               :not_set_up_yet,
                               training_provider: another_provider,
                               ratifying_provider: providers_needing_set_up.last)
        relationship3 = create(:provider_relationship_permissions,
                               :not_set_up_yet,
                               training_provider: providers_needing_set_up.first,
                               ratifying_provider: other_providers.first)
        allow(ProviderSetup).to receive(:new).and_return(instance_double(ProviderSetup, relationships_pending: [relationship1, relationship2, relationship3]))

        described_class.new.perform(service)

        expected_relationships = {
          providers_needing_set_up.first.name => [ratifying_provider.name, other_providers.first.name],
          providers_needing_set_up.last.name => [another_provider.name],
        }

        expect(ProviderMailer).to have_received(:set_up_organisation_permissions).with(provider_users_who_need_to_set_up_permissions.first, expected_relationships)
        expect(ProviderMailer).to have_received(:set_up_organisation_permissions).with(provider_users_who_need_to_set_up_permissions.last, expected_relationships)
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

      context 'when a user has yet to receive the setup permissions email but has received the service open mail' do
        it 'sends the setup permissions email only' do
          ratifying_provider = create(:provider, :with_signed_agreement, name: 'QQQ')
          relationship = create(:provider_relationship_permissions,
                                :not_set_up_yet,
                                training_provider: providers_needing_set_up.first,
                                ratifying_provider: ratifying_provider)
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
    end

    context 'when the specified service is :apply' do
      let(:service) { :apply }

      around do |example|
        Timecop.freeze(CycleTimetable.apply_opens.change(hour: 15)) do
          example.run
        end
      end

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

    context 'with multiple hours remaining' do
      let(:service) { :apply }

      it 'divides the providers with users who should be notified across the hours remaining' do
        Timecop.freeze(CycleTimetable.apply_opens.change(hour: 14)) do
          described_class.new.perform(service)

          expect(ProviderMailer).to have_received(:apply_service_is_now_open).with(provider_users_who_need_to_set_up_permissions.first)
          expect(ProviderMailer).to have_received(:apply_service_is_now_open).with(provider_users_who_need_to_set_up_permissions.last)

          expect(ProviderMailer).not_to have_received(:apply_service_is_now_open).with(other_provider_users.first)
          expect(ProviderMailer).not_to have_received(:apply_service_is_now_open).with(other_provider_users.last)

          described_class.new.perform(service)

          expect(ProviderMailer).to have_received(:apply_service_is_now_open).with(other_provider_users.first)
          expect(ProviderMailer).to have_received(:apply_service_is_now_open).with(other_provider_users.last)
        end
      end
    end

    context 'when called out of hours for the Find service opening' do
      let(:service) { :find }

      it 'does nothing' do
        Timecop.freeze(CycleTimetable.find_opens.change(hour: 8, min: 59)) do
          expect { described_class.new.perform(service) }.not_to change(ChaserSent, :count)
        end
      end
    end

    context 'when called out of hours for the Apply service opening' do
      let(:service) { :apply }

      it 'does nothing' do
        Timecop.freeze(CycleTimetable.apply_opens.change(hour: 16, min: 2)) do
          expect { described_class.new.perform(service) }.not_to change(ChaserSent, :count)
        end
      end
    end
  end
end
