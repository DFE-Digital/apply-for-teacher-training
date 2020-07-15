require 'rails_helper'

RSpec.describe GetApplicationFormsWaitingForProviderDecision do
  let(:chase_date) { TimeLimitCalculator.new(rule: :chase_provider_before_rbd, effective_date: Time.zone.now).call.fetch(:time_in_future) }

  def create_application(status:, reject_by_default_at:)
    create(
      :application_choice,
      status: status,
      reject_by_default_at: reject_by_default_at,
    )
  end

  it 'returns an application where the RBD date is nearer than the chase_date' do
    application_choice = create_application(
      status: 'awaiting_provider_decision',
      reject_by_default_at: chase_date - 1,
    )
    expect(described_class.call).to include application_choice
  end

  it 'does not return an application where the RBD date is beyond the chase date' do
    application_choice = create_application(
      status: 'awaiting_provider_decision',
      reject_by_default_at: chase_date + 1,
    )

    expect(described_class.call).not_to include application_choice
  end

  it 'does not return an application where the RBD date is nearer than the chase date if the chaser has already been sent' do
    application_choice = create_application(
      status: 'awaiting_provider_decision',
      reject_by_default_at: chase_date - 1,
    )

    ChaserSent.create!(chased: application_choice, chaser_type: :provider_decision_request)

    expect(described_class.call).not_to include application_choice
  end
end
