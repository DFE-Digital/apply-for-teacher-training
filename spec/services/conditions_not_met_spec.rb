require 'rails_helper'

RSpec.describe ConditionsNotMet do
  it 'raises an error if the user is not authorised' do
    application_choice = create(:application_choice, status: :pending_conditions)
    provider_user = create(:provider_user)
    provider_user.providers << application_choice.current_course.provider

    service = ConditionsNotMet.new(
      actor: provider_user,
      application_choice: application_choice,
    )

    expect { service.save }.to raise_error(ProviderAuthorisation::NotAuthorisedError)

    expect(application_choice.reload.status).to eq 'pending_conditions'
  end

  it 'sets the conditions_not_met_at date for the application_choice' do
    application_choice = create(:application_choice, status: :pending_conditions)

    Timecop.freeze do
      expect {
        ConditionsNotMet.new(
          actor: create(:support_user),
          application_choice: application_choice,
        ).save
      }.to change { application_choice.conditions_not_met_at }.to(Time.zone.now)
    end
  end
end
