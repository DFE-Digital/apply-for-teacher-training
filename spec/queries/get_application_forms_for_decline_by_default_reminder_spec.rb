require 'rails_helper'

RSpec.describe GetApplicationFormsForDeclineByDefaultReminder do
  let(:chase_date) { TimeLimitCalculator.new(rule: :chase_candidate_before_dbd, effective_date: Time.zone.now).call.fetch(:time_in_future) }

  def create_application(status:, decline_by_default_at:, application_form: create(:application_form))
    create(
      :application_choice,
      application_form: application_form,
      status: status,
      decline_by_default_at: decline_by_default_at,
    )
  end

  it 'returns an application where the DBD date is nearer than the chase_date' do
    application_form = create_application(
      status: 'offer',
      decline_by_default_at: chase_date - 1,
    ).application_form

    expect(described_class.call).to include application_form
  end

  it 'does not return an application where the DBD date is beyond the chase date' do
    create_application(
      status: 'offer',
      decline_by_default_at: chase_date + 1,
    )

    expect(described_class.call).to be_empty
  end

  it 'does not return an application where the DBD date is nearer than the chase date if the chaser has already been sent' do
    application_form = create_application(
      status: 'offer',
      decline_by_default_at: chase_date - 1,
    ).application_form

    ChaserSent.create!(chased: application_form, chaser_type: :candidate_decision_request)

    expect(described_class.call).not_to include application_form
  end
end
