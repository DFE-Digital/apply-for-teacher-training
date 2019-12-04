require 'rails_helper'

RSpec.describe GetApplicationChoicesReadyToDeclineByDefault do
  around do |example|
    Timecop.freeze(Time.zone.local(2019, 12, 4, 12, 0, 0)) do
      example.run
    end
  end

  let(:application_form) { create :application_form }

  def create_application(status:, decline_by_default_at:)
    create(
      :application_choice,
      application_form: application_form,
      status: status,
      decline_by_default_at: decline_by_default_at,
    )
  end

  it 'returns application choices with decline_by_default_at in the past' do
    create_application(
      status: 'offer',
      decline_by_default_at: 1.business_days.ago,
    )
    create_application(
      status: 'offer',
      decline_by_default_at: 2.business_days.from_now,
    )
    create_application(
      status: 'offer',
      decline_by_default_at: 3.business_days.ago,
    )
    Timecop.travel(1.business_days.from_now) do
      choices = described_class.call
      expect(choices).to include application_form.application_choices.first
      expect(choices).not_to include application_form.application_choices.second
      expect(choices).to include application_form.application_choices.third
    end
  end

  it 'does not return application choices unless they are in :offer state' do
    create_application(
      status: 'offer',
      decline_by_default_at: 1.business_days.ago,
    )
    create_application(
      status: 'awaiting_provider_decision',
      decline_by_default_at: 1.business_days.ago,
    )
    Timecop.travel(1.business_days.from_now) do
      expect(described_class.call).to include application_form.application_choices.first
      expect(described_class.call).not_to include application_form.application_choices.second
    end
  end
end
