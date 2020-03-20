require 'rails_helper'

RSpec.describe RecalculateDates do
  around do |example|
    Timecop.freeze(Time.zone.local(2020, 3, 20)) do
      example.run
    end
  end

  after do
    unmock_holidays
  end

  it 'recalculates reject_by_default_at for a submitted application choice' do
    application_form = create(:completed_application_form, :with_completed_references, submitted_at: Time.zone.now)
    application_choice = create(:submitted_application_choice, application_form: application_form)

    mock_holidays

    RecalculateDates.new.perform

    new_reject_by_default = Time.zone.local(2020, 5, 21).end_of_day

    expect(application_choice.reload.reject_by_default_at).to be_within(1.second).of new_reject_by_default
  end

  it 'recalculates decline_by_default_at for a submitted application choice with an offer' do
    application_form = create(:completed_application_form, :with_completed_references, submitted_at: Time.zone.now)
    application_choice = create(
      :submitted_application_choice, :with_offer,
      application_form: application_form,
      decline_by_default_at: 10.business_days.from_now,
      offered_at: Time.zone.now
    )

    mock_holidays

    RecalculateDates.new.perform

    new_decline_by_default = Time.zone.local(2020, 4, 6).end_of_day

    expect(application_choice.reload.decline_by_default_at).to be_within(1.second).of new_decline_by_default
  end

  def mock_holidays
    BusinessTime::Config.holidays << Date.new(2020, 3, 23)
  end

  def unmock_holidays
    BusinessTime::Config.holidays - [Date.new(2020, 3, 23)]
  end
end
