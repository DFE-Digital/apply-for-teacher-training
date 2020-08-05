require 'rails_helper'

RSpec.describe ConfirmEnrolment do
  it 'raises an error if the user is not authorised' do
    application_choice = create(:application_choice, status: :recruited)
    provider_user = create(:provider_user)
    provider_user.providers << application_choice.offered_course.provider

    FeatureFlag.activate(:providers_can_manage_users_and_permissions)

    service = ConfirmEnrolment.new(
      actor: provider_user,
      application_choice: application_choice,
    )

    expect { service.save }.to raise_error(ProviderAuthorisation::NotAuthorisedError)

    expect(application_choice.reload.status).to eq 'recruited'
  end

  it 'sets the enrolled_at date for the application_choice' do
    application_choice = create(:application_choice, status: :recruited)

    Timecop.freeze do
      expect {
        ConfirmEnrolment.new(
          actor: create(:support_user),
          application_choice: application_choice,
        ).save
      }.to change { application_choice.enrolled_at }.to(Time.zone.now)
    end
  end
end
