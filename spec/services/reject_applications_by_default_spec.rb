require 'rails_helper'

RSpec.describe RejectApplicationsByDefault do
  let!(:application_choice) { create(:application_choice, :awaiting_provider_decision, reject_by_default_at: 1.business_days.ago) }

  it 'rejects an application that is ready for rejection but leaves other untouched' do
    other_application_choice = create(:application_choice, :awaiting_provider_decision, reject_by_default_at: 1.business_day.from_now)

    described_class.new.call
    expect(other_application_choice.reload.status).to eq('awaiting_provider_decision')
    expect(application_choice.reload.status).to eq('rejected')
  end

  it 'sends a Slack notification if all candidate applications have ended without success' do
    create(:application_choice, :with_rejection_by_default, application_form: application_choice.application_form)
    notifier = instance_double(StateChangeNotifier, application_outcome_notification: nil)
    allow(StateChangeNotifier).to receive(:new).and_return(notifier)

    described_class.new.call

    expect(StateChangeNotifier).to have_received(:new).with(:rejected, application_choice)
    expect(notifier).to have_received(:application_outcome_notification)
  end
end
