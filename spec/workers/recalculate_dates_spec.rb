require 'rails_helper'

RSpec.describe RecalculateDates do
  it 'recalculates reject_by_default_at for a submitted application choice' do
    application_choice = create(:submitted_application_choice, sent_to_provider_at: Time.zone.now)

    described_class.new.perform

    expect(application_choice.reload.reject_by_default_at).not_to be_nil
  end

  it 'recalculates decline_by_default_at for a submitted application choice with an offer' do
    application_form = create(
      :application_form,
      :with_completed_references,
      submitted_at: Time.zone.now,
    )

    application_choice = create(
      :submitted_application_choice,
      :with_offer,
      application_form: application_form,
      decline_by_default_at: nil,
      offered_at: Time.zone.now,
    )

    described_class.new.perform

    expect(application_choice.reload.decline_by_default_at).not_to be_nil
  end
end
