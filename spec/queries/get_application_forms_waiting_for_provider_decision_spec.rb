require 'rails_helper'

RSpec.describe GetApplicationFormsWaitingForProviderDecision do
  let(:current_time) { Time.zone.local(2019, 6, 1, 12, 0, 0) }
  let(:time_limit_before_rbd) { TimeLimitConfig.limits_for(:chase_provider_before_rbd).first.limit }

  around do |example|
    Timecop.freeze(current_time) do
      example.run
    end
  end

  def create_application(status:, reject_by_default_at:)
    create(
      :application_choice,
      status: status,
      reject_by_default_at: reject_by_default_at,
    )
  end

  it 'returns an application that has not more than the defined limit till RBD date' do
    application_choice = create_application(
      status: 'awaiting_provider_decision',
      reject_by_default_at: time_limit_before_rbd.business_days.from_now,
    )
    expect(described_class.call).to include application_choice
  end

  it 'does not return an application that has more than the defined limit till RBD date' do
    application_choice = create_application(
      status: 'awaiting_provider_decision',
      reject_by_default_at: (time_limit_before_rbd + 1).business_days.from_now,
    )

    expect(described_class.call).not_to include application_choice
  end

  it 'does not return an application if it has been chased already' do
    application_choice = create_application(
      status: 'awaiting_provider_decision',
      reject_by_default_at: time_limit_before_rbd.business_days.from_now,
    )

    ChaserSent.create!(chased: application_choice, chaser_type: :provider_decision_request)

    expect(described_class.call).not_to include application_choice
  end
end
