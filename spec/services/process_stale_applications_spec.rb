require 'rails_helper'

RSpec.describe ProcessStaleApplications do
  it 'rejects an application that is ready for rejection but leaves others untouched' do
    application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      :continuous_applications,
      reject_by_default_at: 1.business_days.ago,
    )

    other_application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      :continuous_applications,
      reject_by_default_at: 1.business_day.from_now,
    )

    interviewing_application_choice = create(
      :application_choice,
      :interviewing,
      :continuous_applications,
      reject_by_default_at: 1.business_day.from_now,
    )

    described_class.new.call
    expect(other_application_choice.reload.status).to eq('awaiting_provider_decision')
    expect(interviewing_application_choice.reload.status).to eq('interviewing')
    expect(application_choice.reload.status).to eq('inactive')
  end

  it 'does not update already inactive applications' do
    inactive_at = 1.business_days.ago.to_time

    application_choice = create(
      :application_choice,
      :inactive,
      :continuous_applications,
      reject_by_default_at: 1.minute.ago,
      inactive_at:,
    )
    other_application_choice = create(
      :application_choice,
      :inactive,
      :continuous_applications,
      reject_by_default_at: 1.minute.ago,
      inactive_at:,
    )

    described_class.new.call
    expect(other_application_choice.reload.status).to eq('inactive')
    expect(other_application_choice.reload.inactive_at).to eq(inactive_at)
    expect(application_choice.reload.status).to eq('inactive')
    expect(application_choice.reload.inactive_at).to eq(inactive_at)
  end
end
