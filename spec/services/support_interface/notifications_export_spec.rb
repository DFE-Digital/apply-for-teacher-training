require 'rails_helper'

RSpec.describe SupportInterface::NotificationsExport do
  describe '#data_for_export' do
    let(:provider1) { create(:provider, code: 'ABC') }
    let(:provider2) { create(:provider, code: 'XYZ') }
    let(:provider_user1) { create(:provider_user, create_notification_preference: false, providers: [provider1, provider2]) }
    let(:provider_user2) { create(:provider_user, create_notification_preference: false, providers: [provider1, provider2]) }

    before do
      create(
        :provider_user_notification_preferences,
        provider_user: provider_user1,
        application_received: false,
        application_withdrawn: true,
        application_rejected_by_default: false,
        offer_accepted: true,
        offer_declined: false,
      )

      create(
        :provider_user_notification_preferences,
        provider_user: provider_user2,
        application_received: true,
        application_withdrawn: false,
        application_rejected_by_default: true,
        offer_accepted: false,
        offer_declined: true,
      )

      provider_user1.provider_permissions.where(provider: provider1).update(make_decisions: true)
    end

    it_behaves_like 'a data export'

    it 'exports notification preferences for provider users per organisation' do
      results = described_class.new.data_for_export

      expect(results.size).to eq(4)
      expect(results).to eq([
        {
          provider_user_id: provider_user1.id,
          notification_application_received: false,
          notification_application_withdrawn: true,
          notification_application_rbd: false,
          notification_offer_accepted: true,
          notification_offer_declined: false,
          permissions_make_decisions: true,
          provider_code: provider1.code,
        },
        {
          provider_user_id: provider_user1.id,
          notification_application_received: false,
          notification_application_withdrawn: true,
          notification_application_rbd: false,
          notification_offer_accepted: true,
          notification_offer_declined: false,
          permissions_make_decisions: false,
          provider_code: provider2.code,
        },
        {
          provider_user_id: provider_user2.id,
          notification_application_received: true,
          notification_application_withdrawn: false,
          notification_application_rbd: true,
          notification_offer_accepted: false,
          notification_offer_declined: true,
          permissions_make_decisions: false,
          provider_code: provider1.code,
        },
        {
          provider_user_id: provider_user2.id,
          notification_application_received: true,
          notification_application_withdrawn: false,
          notification_application_rbd: true,
          notification_offer_accepted: false,
          notification_offer_declined: true,
          permissions_make_decisions: false,
          provider_code: provider2.code,
        },
      ])
    end
  end
end
