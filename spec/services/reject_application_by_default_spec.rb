require 'rails_helper'

RSpec.describe RejectApplicationByDefault do
  let(:application_choice) do
    create(:application_choice, status: 'awaiting_provider_decision', reject_by_default_at: 2.business_days.ago)
  end

  it 'updates the application_choice and calls the SetDeclineByDefault service' do
    service_double = instance_double(SetDeclineByDefault)
    allow(service_double).to receive(:call)

    allow(SetDeclineByDefault).to receive(:new).and_return(service_double)

    described_class.new(application_choice: application_choice).call

    expect(application_choice.status).to eq 'rejected'
    expect(application_choice.rejected_by_default).to be true
    expect(application_choice.rejected_at).not_to be_nil
    expect(service_double).to have_received(:call)
  end
end
