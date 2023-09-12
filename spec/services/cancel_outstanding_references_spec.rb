require 'rails_helper'

RSpec.describe CancelOutstandingReferences, :sidekiq do
  let(:service) { described_class.new(application_form: application_form) }

  let(:application_form) { create(:application_form, :minimum_info) }
  let!(:requested_reference) { create(:reference, :feedback_requested, application_form: application_form) }
  let!(:provided_reference) { create(:reference, :feedback_provided, application_form: application_form) }

  it 'cancel the requested references' do
    service.call!

    expect(requested_reference.reload.feedback_status).to eq('cancelled')
    expect(provided_reference.reload.feedback_status).to eq('feedback_provided')
  end

  it 'deliver email to requested references' do
    service.call!

    expect(ActionMailer::Base.deliveries.map(&:to).flatten).to contain_exactly(requested_reference.email_address)
  end
end
