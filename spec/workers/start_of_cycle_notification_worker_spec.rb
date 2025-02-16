require 'rails_helper'

RSpec.describe StartOfCycleNotificationWorker do
  let(:timetable) { RecruitmentCycleTimetable.current_timetable }

  describe 'throttling' do
    shared_examples 'throttled email' do |number_of_records, start_hour, expected_limit|
      it "fetches #{expected_limit} of records for #{number_of_records} total records at #{start_hour}" do
        collection = instance_double(ActiveRecord::Relation, count: number_of_records, limit: nil).as_null_object
        allow(GetProvidersToNotifyAboutFindAndApply).to receive(:call).and_return(collection)
        allow(collection).to receive(:limit).and_return([])

        travel_temporarily_to(timetable.find_opens_at.change(hour: start_hour)) do
          described_class.new.perform('find')
        end
        expect(collection).to have_received(:limit).with(expected_limit)
      end
    end

    context 'with 10 records' do
      it_behaves_like 'throttled email', 10, 9, 1
      it_behaves_like 'throttled email', 10, 12, 2
      it_behaves_like 'throttled email', 10, 13, 2
      it_behaves_like 'throttled email', 10, 15, 5
    end

    context 'with 100 records' do
      it_behaves_like 'throttled email', 100, 9, 12
      it_behaves_like 'throttled email', 100, 12, 20
      it_behaves_like 'throttled email', 100, 13, 25
      it_behaves_like 'throttled email', 100, 15, 50
    end

    context 'with 1000 records' do
      it_behaves_like 'throttled email', 1000, 9, 125
      it_behaves_like 'throttled email', 1000, 12, 200
      it_behaves_like 'throttled email', 1000, 13, 250
      it_behaves_like 'throttled email', 1000, 15, 500
    end
  end

  describe 'it does not send emails before the cycle has started' do
    it 'does not fetch records at 5am' do
      collection = instance_double(ActiveRecord::Relation).as_null_object
      allow(GetProvidersToNotifyAboutFindAndApply).to receive(:call).and_return(collection)
      allow(collection).to receive(:limit).and_return([])

      travel_temporarily_to(timetable.find_opens_at.change(hour: 5)) do
        described_class.new.perform('find')
      end

      expect(collection).not_to have_received(:limit)
    end

    it 'does not fetch records at 1am' do
      collection = instance_double(ActiveRecord::Relation).as_null_object
      allow(GetProvidersToNotifyAboutFindAndApply).to receive(:call).and_return(collection)
      allow(collection).to receive(:limit).and_return([])

      travel_temporarily_to(timetable.find_opens_at.change(hour: 1)) do
        described_class.new.perform('find')
      end

      expect(collection).not_to have_received(:limit)
    end
  end

  describe '#perform' do
    let(:mailer_delivery) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }
    let(:providers_needing_set_up) { %w[AAA BBB].map { |name| create(:provider, :no_users, name:) } }
    let(:provider_users_who_need_to_set_up_permissions) do
      create_list(:provider_user, 2, providers: providers_needing_set_up)
    end

    let(:other_provider) { create(:provider, name: 'CCC') }
    let(:other_provider_user) { create(:provider_user, providers: [other_provider]) }
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
      other_provider_user.provider_permissions.update(manage_organisations: true)
      providers_needing_set_up.each { |provider| create(:provider_relationship_permissions, :not_set_up_yet, training_provider: provider) }
    end

    context 'when the specified service is find' do
      let(:service) { 'find' }

      before do
        TestSuiteTimeMachine.travel_permanently_to(timetable.find_opens_at.change(hour: 16))
      end

      it 'notifies all provider users that the service is open' do
        described_class.new.perform(service)

        expect(ProviderMailer).to have_received(:find_service_is_now_open).with(provider_users_who_need_to_set_up_permissions.first)
        expect(ProviderMailer).to have_received(:find_service_is_now_open).with(provider_users_who_need_to_set_up_permissions.last)
        expect(ProviderMailer).to have_received(:find_service_is_now_open).with(other_provider_user)
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
                               ratifying_provider: other_provider)
        allow(ProviderSetup).to receive(:new).and_return(instance_double(ProviderSetup, relationships_pending: [relationship2, relationship1, relationship3]))

        described_class.new.perform(service)

        expected_relationships = {
          providers_needing_set_up.first.name => [other_provider.name, ratifying_provider.name],
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
          expect(ChaserSent.where(chased: provider_users_who_need_to_set_up_permissions + [other_provider_user])).to be_empty
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

      context 'when a provider user received an email last cycle' do
        it 'they receive another email this cycle' do
          previous_timetable = timetable.relative_previous_timetable
          TestSuiteTimeMachine.travel_permanently_to(previous_timetable.find_opens_at.change(hour: 16))
          described_class.new.perform(service)

          TestSuiteTimeMachine.travel_permanently_to(timetable.find_opens_at.change(hour: 16))
          described_class.new.perform(service)

          expect(ProviderMailer).to have_received(:find_service_is_now_open).with(other_provider_user).twice
        end
      end
    end
  end
end
