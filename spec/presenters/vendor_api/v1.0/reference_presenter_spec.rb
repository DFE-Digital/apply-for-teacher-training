require 'rails_helper'

RSpec.describe 'ReferencePresenter' do
  subject(:reference_json) { reference_presenter.new(version, reference, application_accepted: application_accepted).as_json }

  let(:reference_presenter) { VendorAPI::ReferencePresenter }
  let(:version) { '1.0' }

  let(:reference) {
    create(:reference,
           reference_status,
           name: 'Some Name',
           email_address: 'someone@email.address',
           relationship: 'Some Relationship',
           referee_type: 'academic',
           feedback: 'Some Feedback',
           safeguarding_concerns_status: 'has_safeguarding_concerns_to_declare')
  }

  context 'when the reference has been received and the application has been accepted' do
    let(:reference_status) { :feedback_provided }
    let(:application_accepted) { true }

    it 'includes the all details including `feedback` and `safeguarding_concerns_status`' do
      expected_json = {
        id: reference.id,
        name: 'Some Name',
        email: 'someone@email.address',
        relationship: 'Some Relationship',
        reference: 'Some Feedback',
        referee_type: 'academic',
        safeguarding_concerns: true,
      }.to_json

      expect(reference_json).to eq(expected_json)
    end
  end

  context 'when the reference has not been received' do
    let(:reference_status) { :not_requested_yet }
    let(:application_accepted) { true }

    it 'does not include `feedback` or `safeguarding_concerns_status`' do
      expected_json = {
        id: reference.id,
        name: 'Some Name',
        email: 'someone@email.address',
        relationship: 'Some Relationship',
        reference: nil,
        referee_type: 'academic',
        safeguarding_concerns: nil,
      }.to_json

      expect(reference_json).to eq(expected_json)
    end
  end

  context 'when the application has not been accepted' do
    let(:reference_status) { :feedback_provided }
    let(:application_accepted) { false }

    it 'does not include `feedback` or `safeguarding_concerns_status`' do
      expected_json = {
        id: reference.id,
        name: 'Some Name',
        email: 'someone@email.address',
        relationship: 'Some Relationship',
        reference: nil,
        referee_type: 'academic',
        safeguarding_concerns: nil,
      }.to_json

      expect(reference_json).to eq(expected_json)
    end
  end
end
