require 'rails_helper'

RSpec.describe ConfirmOfferWithPendingSkeConditions do
  it 'raises an error if the user is not authorised' do
    application_choice = create(:application_choice, status: :pending_conditions)
    provider_user = create(:provider_user)
    provider_user.providers << application_choice.current_course.provider

    service = described_class.new(
      actor: provider_user,
      application_choice:,
    )

    expect { service.save }.to raise_error(ProviderAuthorisation::NotAuthorisedError)

    expect(application_choice.reload.status).to eq 'pending_conditions'
  end

  it 'does not alter the status of any offer conditions' do
    application_choice = create(:application_choice, :offered, status: :pending_conditions)
    offer = Offer.find_by(application_choice:)

    expect {
      described_class.new(
        actor: create(:support_user),
        application_choice:,
      ).save
    }.not_to change { offer.conditions.first.status }
  end

  it 'changes the status to recruited' do
    application_choice = create(:application_choice, :offered, status: :pending_conditions)

    described_class.new(
      actor: create(:support_user),
      application_choice:,
    ).save

    expect(application_choice.reload.recruited?).to be(true)
  end
end
