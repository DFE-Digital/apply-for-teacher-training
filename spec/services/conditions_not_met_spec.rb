require 'rails_helper'

RSpec.describe ConditionsNotMet do
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

  it 'sets the conditions_not_met_at date for the application_choice' do
    application_choice = create(:application_choice, :with_offer, status: :pending_conditions)

    Timecop.freeze do
      expect {
        described_class.new(
          actor: create(:support_user),
          application_choice: application_choice,
        ).save
      }.to change { application_choice.conditions_not_met_at }.to(Time.zone.now)
    end
  end

  it 'sets the status of all the offer conditions to unmet' do
    application_choice = create(:application_choice, :with_offer, status: :pending_conditions)
    offer = Offer.find_by(application_choice: application_choice)

    expect {
      described_class.new(
        actor: create(:support_user),
        application_choice: application_choice,
      ).save
    }.to change { offer.reload.conditions.first.status }.from('pending').to('unmet')
  end

  it 'creates an offer object if it does not exist' do
    application_choice = create(:application_choice, offer: { conditions: ['Be cool'] }, status: :pending_conditions)

    described_class.new(
      actor: create(:support_user),
      application_choice: application_choice,
    ).save

    offer = Offer.find_by(application_choice: application_choice)

    expect(offer).not_to be_nil
    expect(offer.conditions.first.status).to eq('unmet')
  end
end
