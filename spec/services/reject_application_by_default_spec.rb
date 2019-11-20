require 'rails_helper'

RSpec.describe RejectApplicationByDefault do
  def create_application
    application_form = create :application_form
    create(
      :application_choice,
      application_form: application_form,
      status: 'awaiting_provider_decision',
      reject_by_default_at: 2.business_days.ago,
    )
  end

  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  it 'sets the status to `rejected`' do
    application_choice = create_application
    described_class.new(application_choice: application_choice).call
    expect(application_choice.reload.status).to eq 'rejected'
  end

  it 'sets `rejected_by_default` to `true`' do
    application_choice = create_application
    described_class.new(application_choice: application_choice).call
    expect(application_choice.reload.rejected_by_default).to be true
  end
end
