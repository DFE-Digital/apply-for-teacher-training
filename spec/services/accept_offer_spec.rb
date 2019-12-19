require 'rails_helper'

RSpec.describe AcceptOffer do
  it 'sets the accepted_at date for the application_choice' do
    application_choice = create(:application_choice, status: :offer)

    Timecop.freeze do
      expect {
        AcceptOffer.new(application_choice: application_choice).save!
      }.to change { application_choice.accepted_at }.to(Time.zone.now)
    end
  end
end
