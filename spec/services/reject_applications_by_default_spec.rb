require 'rails_helper'

RSpec.describe RejectApplicationsByDefault do
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

  it 'rejects an application that is ready for rejection but leaves other untouched' do
    application_form_ready = create_application(
      status: 'awaiting_provider_decision',
      reject_by_default_at: 1.business_days.ago,
    )
    application_form_not_ready = create_application(
      status: 'awaiting_provider_decision',
      reject_by_default_at: 1.business_days.from_now,
    )
    described_class.new.call
    expect(application_form_not_ready.application_choices.first.reload.status).to eq 'awaiting_provider_decision'
    expect(application_form_ready.application_choices.first.reload.status).to eq 'rejected'
  end
end
