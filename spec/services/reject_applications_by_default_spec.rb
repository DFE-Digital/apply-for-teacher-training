require 'rails_helper'

RSpec.describe RejectApplicationsByDefault do
  let!(:application_choice) { create(:application_choice, :awaiting_provider_decision, reject_by_default_at: 1.business_days.ago) }

  it 'rejects an application that is ready for rejection but leaves other untouched' do
    other_application_choice = create(:application_choice, :awaiting_provider_decision, reject_by_default_at: 1.business_day.from_now)

    described_class.new.call
    expect(other_application_choice.reload.status).to eq('awaiting_provider_decision')
    expect(application_choice.reload.status).to eq('rejected')
  end
end
