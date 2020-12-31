require 'rails_helper'

RSpec.describe DeclineOffer do
  it 'sets the declined_at date and sends a Slack notification' do
    application_choice = create(:application_choice, status: :offer)
    notifier = instance_double(StateChangeNotifier, application_outcome_notification: nil)
    allow(StateChangeNotifier).to receive(:new).and_return(notifier)

    Timecop.freeze do
      expect {
        DeclineOffer.new(application_choice: application_choice).save!
      }.to change { application_choice.declined_at }.to(Time.zone.now)

      expect(StateChangeNotifier).to have_received(:new).with(:declined, application_choice)
      expect(notifier).to have_received(:application_outcome_notification)
    end
  end
end
