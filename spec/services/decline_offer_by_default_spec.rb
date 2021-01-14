require 'rails_helper'

RSpec.describe DeclineOfferByDefault do
  let(:application_choice) { create(:application_choice, status: :offer) }

  it 'updates the application_choice and posts Slack notifications' do
    notifier = instance_double(StateChangeNotifier, application_outcome_notification: nil)
    allow(StateChangeNotifier).to receive(:new).and_return(notifier)

    described_class.new(application_form: application_choice.application_form).call

    application_choice.reload

    expect(application_choice.declined_by_default).to eq(true)
    expect(application_choice.declined_at).not_to be_nil

    expect(StateChangeNotifier).to have_received(:new).with(:declined_by_default, application_choice)
    expect(notifier).to have_received(:application_outcome_notification)
  end
end
