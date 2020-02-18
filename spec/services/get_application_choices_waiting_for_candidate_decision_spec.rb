require 'rails_helper'

RSpec.describe GetApplicationChoicesWaitingForCandidateDecision do
  let(:current_time) { Time.zone.local(2019, 6, 1, 12, 0, 0) }
  let(:time_limit_before_dbd) { TimeLimitConfig.limits_for(:chase_candidate_before_dbd).first.limit }

  around do |example|
    Timecop.freeze(current_time) do
      example.run
    end
  end

  def create_application(status:, decline_by_default_at:, application_form: create(:application_form))
    create(
      :application_choice,
      application_form: application_form,
      status: status,
      decline_by_default_at: decline_by_default_at,
    )
  end

  it 'returns application forms that has less than the defined limit till DBD date' do
    application_form = create_application(
      status: 'offer',
      decline_by_default_at: time_limit_before_dbd.business_days.from_now,
    ).application_form

    expect(described_class.call).to include application_form
  end

  it 'does not return application forms that has not exceeeded the DBD date' do
    create_application(
      status: 'offer',
      decline_by_default_at: (time_limit_before_dbd + 1).business_days.from_now,
    )

    expect(described_class.call).to be_empty
  end

  it 'does not return an application forms that has been chased already' do
    application_form = create_application(
      status: 'offer',
      decline_by_default_at: time_limit_before_dbd.business_days.from_now,
    ).application_form

    ChaserSent.create!(chased: application_form, chaser_type: :candidate_decision_request)

    expect(described_class.call).not_to include application_form
  end
end
