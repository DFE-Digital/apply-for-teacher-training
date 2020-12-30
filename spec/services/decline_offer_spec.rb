require 'rails_helper'

RSpec.describe DeclineOffer do
  let(:application_choice) { create(:application_choice, status: :offer) }

  describe 'when provider_user notifications are on' do
    let(:provider_user) { create :provider_user, send_notifications: true, providers: [application_choice.provider] }

    it 'sets the declined_at date for the application_choice and tracks the notification' do
      Timecop.freeze do
        expect {
          described_class.new(application_choice: application_choice).save!
        }.to have_metrics_tracked(application_choice, 'notifications.on', provider_user, :offer_declined)
          .and change { application_choice.declined_at }.to(Time.zone.now)
      end
    end
  end

  describe 'when provider_user notifications are off' do
    let(:provider_user) { create :provider_user, send_notifications: false, providers: [application_choice.provider] }

    it 'tracks that a notification was sent' do
      expect {
        described_class.new(application_choice: application_choice).save!
      }.to have_metrics_tracked(application_choice, 'notifications.off', provider_user, :offer_declined)
    end
  end
end
