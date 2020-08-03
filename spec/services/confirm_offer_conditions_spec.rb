require 'rails_helper'

RSpec.describe ConfirmOfferConditions do
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
