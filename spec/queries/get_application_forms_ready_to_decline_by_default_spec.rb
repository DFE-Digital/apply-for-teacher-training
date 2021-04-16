require 'rails_helper'

RSpec.describe GetApplicationFormsReadyToDeclineByDefault do
  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  def create_application_form(status:, decline_by_default_at:)
    application_choice = create(
      :application_choice,
      status: status,
      decline_by_default_at: decline_by_default_at,
    )

    application_choice.application_form
  end

  it 'returns application choices with decline_by_default_at in the past' do
    expired_application_form = create_application_form(
      status: 'offer',
      decline_by_default_at: 1.business_days.ago,
    )
    not_expired_application_form = create_application_form(
      status: 'offer',
      decline_by_default_at: 2.business_days.from_now,
    )
    Timecop.travel(1.business_days.from_now) do
      application_forms_with_expired_choices = described_class.call
      expect(application_forms_with_expired_choices).to include expired_application_form
      expect(application_forms_with_expired_choices).not_to include not_expired_application_form
    end
  end

  it 'does not return application forms unless they have a choice in offer state' do
    application1 = create_application_form(
      status: 'offer',
      decline_by_default_at: 1.business_days.ago,
    )
    application2 = create_application_form(
      status: 'awaiting_provider_decision',
      decline_by_default_at: 1.business_days.ago,
    )
    Timecop.travel(1.business_days.from_now) do
      expect(described_class.call).to include application1
      expect(described_class.call).not_to include application2
    end
  end
end
