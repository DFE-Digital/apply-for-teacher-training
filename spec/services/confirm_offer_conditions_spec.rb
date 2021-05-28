require 'rails_helper'

RSpec.describe ConfirmOfferConditions do
  it 'raises an error if the user is not authorised' do
    application_choice = create(:application_choice, status: :pending_conditions)
    provider_user = create(:provider_user)
    provider_user.providers << application_choice.current_course.provider

    service = described_class.new(
      actor: provider_user,
      application_choice: application_choice,
    )

    expect { service.save }.to raise_error(ProviderAuthorisation::NotAuthorisedError)

    expect(application_choice.reload.status).to eq 'pending_conditions'
  end

  it 'updates the application_choice and sends a Slack notification' do
    application_choice = create(:application_choice, :with_offer, status: :pending_conditions)
    notifier = instance_double(StateChangeNotifier, application_outcome_notification: nil)
    allow(StateChangeNotifier).to receive(:new).and_return(notifier)

    Timecop.freeze do
      expect {
        described_class.new(
          actor: create(:support_user),
          application_choice: application_choice,
        ).save
      }.to change { application_choice.recruited_at }.to(Time.zone.now)

      expect(StateChangeNotifier).to have_received(:new).with(:recruited, application_choice)
      expect(notifier).to have_received(:application_outcome_notification)
    end
  end

  it 'sets the status of all the offer conditions to met' do
    application_choice = create(:application_choice, :with_offer, status: :pending_conditions)
    offer = Offer.find_by(application_choice: application_choice)

    expect {
      described_class.new(
        actor: create(:support_user),
        application_choice: application_choice,
      ).save
    }.to change { offer.conditions.first.status }.from('pending').to('met')
  end

  it 'creates an offer object if it does not exist' do
    application_choice = create(:application_choice, offer: { conditions: ['Be cool'] }, status: :pending_conditions)

    described_class.new(
      actor: create(:support_user),
      application_choice: application_choice,
    ).save

    offer = Offer.find_by(application_choice: application_choice)

    expect(offer).not_to be_nil
    expect(offer.conditions.first.status).to eq('met')
  end
end
