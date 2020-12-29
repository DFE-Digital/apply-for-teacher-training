require 'rails_helper'

RSpec.describe DeclineOfferByDefault do
  around { |example| perform_enqueued_jobs(&example) }

  it 'sends a notification email to the provider' do
    application_choice = create(:application_choice, status: :offer, declined_at: nil)
    application_form = application_choice.application_form
    provider_user = create :provider_user, send_notifications: true, providers: [application_choice.provider]

    expect {
      described_class.new(application_form: application_form).call
    }.to have_metrics_tracked(application_choice, 'notifications.on', provider_user, :offer_declined_by_default)
      .and change { ActionMailer::Base.deliveries.count }.by(2)
  end

  it 'sends an email to the candidate' do
    application_choice = create(:application_choice, status: :offer)
    application_form = application_choice.application_form

    expect { described_class.new(application_form: application_form).call }
      .to change { ActionMailer::Base.deliveries.count }.by(1)

    expect(ActionMailer::Base.deliveries.first.to).to eq [application_choice.application_form.candidate.email_address]
    expect(ActionMailer::Base.deliveries.first.subject).to match(/You did not respond to your offe/)
  end
end
