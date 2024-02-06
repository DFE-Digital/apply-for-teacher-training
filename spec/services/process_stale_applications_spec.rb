require 'rails_helper'

RSpec.describe ProcessStaleApplications do
  it 'rejects an application that is ready for rejection but leaves others untouched' do
    application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      reject_by_default_at: 1.business_days.ago,
    )

    other_application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      reject_by_default_at: 1.business_day.from_now,
    )

    interviewing_application_choice = create(
      :application_choice,
      :interviewing,
      reject_by_default_at: 1.business_day.from_now,
    )

    described_class.new.call
    expect(other_application_choice.reload.status).to eq('awaiting_provider_decision')
    expect(interviewing_application_choice.reload.status).to eq('interviewing')
    expect(application_choice.reload.status).to eq('inactive')
  end

  it 'does not update already inactive applications' do
    inactive_at = Time.zone.local(2023, 12, 1)

    application_choice = create(
      :application_choice,
      :inactive,
      inactive_at:,
    )
    other_application_choice = create(
      :application_choice,
      :inactive,
      inactive_at:,
    )

    described_class.new.call
    expect(other_application_choice.reload.status).to eq('inactive')
    expect(other_application_choice.reload.inactive_at).to eq(inactive_at)
    expect(application_choice.reload.status).to eq('inactive')
    expect(application_choice.reload.inactive_at).to eq(inactive_at)
  end
end
