require 'rails_helper'

RSpec.describe SendApplicationToProvider do
  def application_choice(status: 'unsubmitted')
    @application_choice ||= create(
      :application_choice,
      :with_completed_application_form,
      status:,
    )
  end

  it 'sets the status to `awaiting_provider_decision`' do
    described_class.new(application_choice:).call

    expect(application_choice.status).to eq 'awaiting_provider_decision'
  end

  it 'sets the `sent_to_provider` date' do
    described_class.new(application_choice:).call

    expect(application_choice.reload.sent_to_provider_at).not_to be_nil
  end

  it 'calls the reject by default service' do
    set_reject_by_default = instance_double(SetRejectByDefault, call: true)
    allow(SetRejectByDefault).to receive(:new).with(application_choice).and_return(set_reject_by_default)

    described_class.new(application_choice:).call

    expect(set_reject_by_default).to have_received(:call)
  end

  it 'emails the provider’s provider users', :sidekiq do
    user = create(:provider_user, :with_notifications_enabled)

    application_choice.provider.provider_users = [user]

    expect {
      described_class.new(application_choice:).call
    }.to change { ActionMailer::Base.deliveries.count }.by(1)

    expect(ActionMailer::Base.deliveries.first.to.first).to eq(user.email_address)
  end

  it 'does not work for applications that are not sendable' do
    expect {
      described_class.new(application_choice: application_choice(status: 'awaiting_provider_decision')).call
    }.to raise_error(described_class::ApplicationNotReadyToSendError)
  end
end
