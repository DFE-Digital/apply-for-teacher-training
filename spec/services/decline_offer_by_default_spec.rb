require 'rails_helper'

RSpec.describe DeclineOfferByDefault do
  let(:application_choice) { create(:application_choice, status: :offer, declined_at: nil) }
  let(:application_form) { application_choice.application_form }

  around { |example| perform_enqueued_jobs(&example) }

  describe 'when provider_user notifications are on' do
    let!(:provider_user) { create(:provider_user, send_notifications: true, providers: [application_choice.provider]) }

    it 'sends a notification email to the provider' do
      expect {
        described_class.new(application_form: application_form).call
      }.to have_metrics_tracked(application_choice, 'notifications.on', provider_user, :offer_declined_by_default)
        .and change { ActionMailer::Base.deliveries.count }.by(2)
    end
  end

  describe 'when provider_user notifications are off' do
    let!(:provider_user) { create(:provider_user, send_notifications: false, providers: [application_choice.provider]) }

    it 'tracks that a notification was sent' do
      expect {
        described_class.new(application_form: application_form).call
      }.to have_metrics_tracked(application_choice, 'notifications.off', provider_user, :offer_declined_by_default)
    end
  end

  it 'sends an email to the candidate' do
    expect { described_class.new(application_form: application_form).call }
      .to change { ActionMailer::Base.deliveries.count }.by(1)

    expect(ActionMailer::Base.deliveries.first.to).to eq [application_choice.application_form.candidate.email_address]
    expect(ActionMailer::Base.deliveries.first.subject).to match(/You did not respond to your offe/)
  end
end
