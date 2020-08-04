require 'rails_helper'

RSpec.describe ConfirmOfferConditions do
  it 'raises an error if the user is not authorised' do
    application_choice = create(:application_choice, status: :pending_conditions)
    provider_user = create(:provider_user)
    provider_user.providers << application_choice.offered_course.provider

    FeatureFlag.activate(:providers_can_manage_users_and_permissions)

    service = ConfirmOfferConditions.new(
      actor: provider_user,
      application_choice: application_choice,
    )

    expect { service.save }.to raise_error(ProviderAuthorisation::NotAuthorisedError)

    expect(application_choice.reload.status).to eq 'pending_conditions'
  end

  it 'sets the recruited_at date for the application_choice' do
    application_choice = create(:application_choice, status: :pending_conditions)

    Timecop.freeze do
      expect {
        ConfirmOfferConditions.new(
          actor: create(:support_user),
          application_choice: application_choice,
        ).save
      }.to change { application_choice.recruited_at }.to(Time.zone.now)
    end
  end
end
