require 'rails_helper'

RSpec.describe RecalculateDates do
  after do
    unmock_holidays
  end

  it 'recalculates reject_by_default_at for a submitted application choice' do
    application_form = create(:completed_application_form, :with_completed_references, submitted_at: Time.zone.local(2020, 3, 20))
    application_choice = create(:submitted_application_choice, application_form: application_form)

    mock_holidays

    RecalculateDates.new.perform

    new_reject_by_default = Time.zone.local(2020, 5, 21).end_of_day

    expect(application_choice.reload.reject_by_default_at).to be_within(1.second).of new_reject_by_default
  end

  def mock_holidays
    BusinessTime::Config.holidays << Date.new(2020, 3, 23)
  end

  def unmock_holidays
    BusinessTime::Config.holidays - [Date.new(2020, 3, 23)]
  end
end
