require 'rails_helper'

RSpec.describe GetApplicationChoicesReadyToRejectByDefault do
  around do |example|
    Timecop.freeze(Time.zone.local(2019, 6, 1, 12, 0, 0)) do
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

  it 'returns an application with reject_by_default_at 1 working days ago' do
    application_form = create_application(
      status: 'awaiting_provider_decision',
      reject_by_default_at: 1.business_days.ago,
    )
    Timecop.travel(1.business_days.from_now) do
      expect(described_class.call).to include application_form.application_choices.first
    end
  end

  it 'does not return an application with reject_by_default_at 1 working days ago if it has been offered already' do
    application_form = create_application(
      status: 'offer',
      reject_by_default_at: 1.business_days.ago,
    )
    Timecop.travel(1.business_days.from_now) do
      expect(described_class.call).not_to include application_form.application_choices.first
    end
  end

  it 'does not return an application with reject_by_default_at 1 working days in the future' do
    application_form = create_application(
      status: 'awaiting_provider_decision',
      reject_by_default_at: 1.business_days.from_now,
    )
    expect(described_class.call).not_to include application_form.application_choices.first
  end
end
