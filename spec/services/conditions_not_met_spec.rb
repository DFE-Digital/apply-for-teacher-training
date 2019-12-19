require 'rails_helper'

RSpec.describe ConditionsNotMet do
  it 'sets the conditions_not_met_at date for the application_choice' do
    application_choice = create(:application_choice, status: :pending_conditions)

    Timecop.freeze do
      expect {
        ConditionsNotMet.new(application_choice: application_choice).save
      }.to change { application_choice.conditions_not_met_at }.to(Time.zone.now)
    end
  end
end
