require 'rails_helper'

RSpec.describe SendApplicationToProvider do
  def create_application
    application_form = create :application_form
    create(
      :application_choice,
      application_form: application_form,
      status: 'application_complete',
      edit_by: 2.business_days.ago,
    )
  end

  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  it 'sets the status to `awaiting_provider_decision`' do
    application_choice = create_application
    SendApplicationToProvider.new(application_choice: application_choice).call
    expect(application_choice.reload.status).to eq 'awaiting_provider_decision'
  end

  it 'sets the `reject_by_default_at` date and `reject_by_default_days`' do
    time_limit_calculator = instance_double(TimeLimitCalculator, call: 20)
    allow(TimeLimitCalculator).to receive(:new).and_return(time_limit_calculator)
    application_choice = create_application
    SendApplicationToProvider.new(application_choice: application_choice).call
    expect(application_choice.reload.reject_by_default_at.round).to eq 20.business_days.from_now.end_of_day.round
    expect(application_choice.reject_by_default_days).to eq 20
  end

  it 'sends a Slack notification' do
    application_choice = create_application
    expect(SlackNotificationWorker).to receive(:perform_async)
    SendApplicationToProvider.new(application_choice: application_choice).call
  end
end
