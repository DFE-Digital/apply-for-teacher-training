require 'rails_helper'

RSpec.describe GetApplicationFormsWaitingForProviderDecision do
  let(:current_time) { Time.zone.local(2019, 6, 1, 12, 0, 0) }

  around do |example|
    Timecop.freeze(current_time) do
      example.run
    end
  end

  def create_application(status:, reject_by_default_at:)
    application_form = create :application_form
    create(
      :application_choice,
      application_form: application_form,
      status: status,
      reject_by_default_at: reject_by_default_at,
    )
    application_form.reload
  end

  it 'returns an application that has not more than 20 working days till RBD date' do
    application_form = create_application(
      status: 'awaiting_provider_decision',
      reject_by_default_at: 21.business_days.from_now,
    )

    Timecop.travel(1.business_days.from_now) do
      expect(described_class.call).to include application_form.application_choices.first
    end
  end

  it 'does not return an application that has more than 20 working days till RBD date' do
    application_form = create_application(
      status: 'awaiting_provider_decision',
      reject_by_default_at: 22.business_days.from_now,
    )
    Timecop.travel(1.business_days.from_now) do
      expect(described_class.call).not_to include application_form.application_choices.first
    end
  end

  it 'does not return an application if it has been chased already' do
    application_form = create_application(
      status: 'awaiting_provider_decision',
      reject_by_default_at: 10.business_days.from_now,
    )

    ChaserSent.create!(chased: application_form.application_choices.first, chaser_type: :provider_decision_request)

    Timecop.travel(1.business_days.from_now) do
      expect(described_class.call).not_to include application_form.application_choices.first
    end
  end
end
