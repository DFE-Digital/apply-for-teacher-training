require 'rails_helper'

RSpec.describe RejectApplication do
  let(:application_choice) do
    create(
      :application_choice,
      status: 'awaiting_provider_decision',
    )
  end

  it 'does not save if there are not rejection reasons' do
    described_class.new(application_choice: application_choice).save
    expect(application_choice.reload.status).to eq 'awaiting_provider_decision'
    expect(application_choice.reload.structured_rejection_reasons).to be nil
  end

  it 'sets the status to `rejected`' do
    described_class.new(
      application_choice: application_choice,
      rejection_reasons: 'something went wrong',
    ).save
    expect(application_choice.reload.status).to eq 'rejected'
  end

  it 'sets `structured_rejection_reasons`' do
    described_class.new(
      application_choice: application_choice,
      rejection_reasons: 'something went wrong',
    ).save
    expect(application_choice.reload.structured_rejection_reasons).not_to be nil
  end

  it 'sets `rejected_at`' do
    described_class.new(
      application_choice: application_choice,
      rejection_reasons: 'something went wrong',
    ).save
    expect(application_choice.reload.rejected_at).not_to be_nil
  end
end
