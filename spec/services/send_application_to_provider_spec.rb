require 'rails_helper'

RSpec.describe SendApplicationToProvider do
  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  def application_choice(status: 'unsubmitted')
    @application_choice ||= create(
      :submitted_application_choice,
      :with_completed_application_form,
      status: status,
    )
  end

  it 'sets the status to `awaiting_provider_decision`' do
    described_class.new(application_choice: application_choice).call

    expect(application_choice.status).to eq 'awaiting_provider_decision'
  end

  it 'sets the `sent_to_provider` date' do
    described_class.new(application_choice: application_choice).call

    expect(application_choice.reload.sent_to_provider_at).not_to be_nil
  end

  it 'sets the `reject_by_default_at` date and `reject_by_default_days`' do
    reject_by_default_at = 20.business_days.from_now.end_of_day
    time_limit_calculator = instance_double(TimeLimitCalculator, call: { days: 20, time_in_future: reject_by_default_at })
    allow(TimeLimitCalculator).to receive(:new).and_return(time_limit_calculator)

    described_class.new(application_choice: application_choice).call

    expect(application_choice.reload.reject_by_default_at.round).to eq reject_by_default_at.round
    expect(application_choice.reject_by_default_days).to eq 20
  end

  it 'emails the provider’s provider users', sidekiq: true do
    user = create(:provider_user, :with_notifications_enabled)

    application_choice.provider.provider_users = [user]

    expect {
      described_class.new(application_choice: application_choice).call
    }.to change { ActionMailer::Base.deliveries.count }.by(1)

    expect(ActionMailer::Base.deliveries.first.to.first).to eq(user.email_address)
  end

  it 'does not work for applications that are not sendable' do
    expect {
      described_class.new(application_choice: application_choice(status: 'awaiting_provider_decision')).call
    }.to raise_error(described_class::ApplicationNotReadyToSendError)
  end
end
