require 'rails_helper'

RSpec.describe DeclineOffer do
  it 'sets the declined_at date for the application_choice' do
    application_choice = create(:application_choice, status: :offer)
    provider_user = create :provider_user, send_notifications: true, providers: [application_choice.provider]

    Timecop.freeze do
      expect {
        described_class.new(application_choice: application_choice).save!
      }.to have_metrics_tracked(application_choice, 'notifications.on', provider_user, :offer_declined)
        .and change { application_choice.declined_at }.to(Time.zone.now)
    end
  end
end
