require 'rails_helper'

RSpec.describe SupportInterface::NotificationsExport do
  describe '#data_for_export' do
    it 'returns the correct count for user notification related events' do
      provider = create(:provider)
      provider_user = create(:provider_user, email_address: 'jane@doe.com', providers: [provider], send_notifications: false)
      other_provider_user = create(:provider_user, email_address: 'janice@doe.com', providers: [provider], send_notifications: true)
      application_choice = create(:application_choice)
      application_choice2 = create(:application_choice)
      application_choice3 = create(:application_choice)

      Metrics::Tracker.new(application_choice, 'notifications.on', provider_user).track(:application_submitted)
      Metrics::Tracker.new(application_choice2, 'notifications.off', provider_user).track(:application_submitted)
      Metrics::Tracker.new(application_choice3, 'notifications.off', other_provider_user).track(:application_submitted)
      Metrics::Tracker.new(application_choice, 'notifications.on', provider_user).track(:offer_accepted)
      Metrics::Tracker.new(application_choice2, 'notifications.off', provider_user).track(:offer_declined)
      Metrics::Tracker.new(application_choice3, 'notifications.off', other_provider_user).track(:application_withdrawn)

      expect(described_class.new.data_for_export).to match_array([
        {
          'User' => 'jane@doe.com',
          'Notification Setting' => 'No',
          'No. Notifications received whilst Notifications On' => 2,
          'No. Notifications received whilst Notifications Off' => 2,
          'Number of changes' => 0,
          'Total number of notifications received' => 4,
          'Number of Notifications received for: Application submitted' => 2,
          'Number of Notifications received for: Application submitted with safeguarding issues' => 0,
          'Number of Notifications received for: Application submitted more than 5 days ago (and no response)' => 0,
          'Number of Notifications received for: Application rejected by default' => 0,
          'Number of Notifications received for: Application withdrawn' => 0,
          'Number of Notifications received for: Offer accepted' => 1,
          'Number of Notifications received for: Offer declined' => 1,
          'Number of Notifications received for: Offer declined by default' => 0,
          'Number of Notifications received for: Note added to application' => 0,
          'Number of decision made with Notifications' => 0,
          'Average time from application receipt to decision (for decisions made by this user)' => 0,
          'Average time from application receipt to decision (for decisions made by this user) - Notifications On' => 0,
          'Average time from application receipt to decision (for decisions made by this user) - Notifications Off' => 0,
          'No. Users in Org with Notifications On' => 1,
          'No. Users in Org with Notifications Off' => 1,
          'No. Applications rejected automatically by this organisation' => 0,
        },
        {
          'User' => 'janice@doe.com',
          'Notification Setting' => 'Yes',
          'No. Notifications received whilst Notifications On' => 0,
          'No. Notifications received whilst Notifications Off' => 2,
          'Number of changes' => 0,
          'Total number of notifications received' => 2,
          'Number of Notifications received for: Application submitted' => 1,
          'Number of Notifications received for: Application submitted with safeguarding issues' => 0,
          'Number of Notifications received for: Application submitted more than 5 days ago (and no response)' => 0,
          'Number of Notifications received for: Application rejected by default' => 0,
          'Number of Notifications received for: Application withdrawn' => 1,
          'Number of Notifications received for: Offer accepted' => 0,
          'Number of Notifications received for: Offer declined' => 0,
          'Number of Notifications received for: Offer declined by default' => 0,
          'Number of Notifications received for: Note added to application' => 0,
          'Number of decision made with Notifications' => 0,
          'Average time from application receipt to decision (for decisions made by this user)' => 0,
          'Average time from application receipt to decision (for decisions made by this user) - Notifications On' => 0,
          'Average time from application receipt to decision (for decisions made by this user) - Notifications Off' => 0,
          'No. Users in Org with Notifications On' => 1,
          'No. Users in Org with Notifications Off' => 1,
          'No. Applications rejected automatically by this organisation' => 0,
        },
      ])
    end
  end
end
