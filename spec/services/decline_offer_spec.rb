require 'rails_helper'

RSpec.describe DeclineOffer do
  it 'sets the declined_at date for the application_choice' do
    application_choice = create(:application_choice, status: :offer)

    Timecop.freeze do
      expect {
        DeclineOffer.new(application_choice: application_choice).save!
      }.to change { application_choice.declined_at }.to(Time.zone.now)
    end
  end
end
