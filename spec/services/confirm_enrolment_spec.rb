require 'rails_helper'

RSpec.describe ConfirmEnrolment do
  it 'sets the enrolled_at date for the application_choice' do
    application_choice = create(:application_choice, status: :recruited)

    Timecop.freeze do
      expect {
        ConfirmEnrolment.new(application_choice: application_choice).save
      }.to change { application_choice.enrolled_at }.to(Time.zone.now)
    end
  end
end
