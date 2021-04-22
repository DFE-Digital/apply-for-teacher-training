require 'rails_helper'

RSpec.describe ConfirmOfferConditions do
  it 'raises an error if the user is not authorised' do
    application_choice = create(:application_choice, status: :pending_conditions)
    provider_user = create(:provider_user)
    provider_user.providers << application_choice.current_course.provider

    service = ConfirmOfferConditions.new(
      actor: provider_user,
      application_choice: application_choice,
    )

    expect { service.save }.to raise_error(ProviderAuthorisation::NotAuthorisedError)

    expect(application_choice.reload.status).to eq 'pending_conditions'
  end

  it 'updates the application_choice and sends a Slack notification' do
    application_choice = create(:application_choice, status: :pending_conditions)
    notifier = instance_double(StateChangeNotifier, application_outcome_notification: nil)
    allow(StateChangeNotifier).to receive(:new).and_return(notifier)

    Timecop.freeze do
      expect {
        ConfirmOfferConditions.new(
          actor: create(:support_user),
          application_choice: application_choice,
        ).save
      }.to change { application_choice.recruited_at }.to(Time.zone.now)

      expect(StateChangeNotifier).to have_received(:new).with(:recruited, application_choice)
      expect(notifier).to have_received(:application_outcome_notification)
    end
  end
end
