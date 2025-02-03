require 'rails_helper'

RSpec.describe 'Vendor API - GET /api/v1.6/applications/:application_id' do
  include VendorAPISpecHelpers

  let(:application_form) { create(:completed_application_form, application_references: [reference]) }
  let(:application_choice) { create_application_choice_for_currently_authenticated_provider(attributes) }
  let(:attributes) { { status: 'offer', application_form: } }

  before { get_api_request "/api/v1.6/applications/#{application_choice.id}" }

  context 'when the referee has said the reference is confidential' do
    let(:reference) { create(:reference, :feedback_provided, confidential: true) }

    it 'returns true' do
      expect(response).to have_http_status(:ok)
      references = parsed_response['data']['attributes']['references']
      expect(references.detect { |ref| ref['id'] == reference.id }['confidential']).to be(true)
    end
  end

  context 'when the referee has said the reference is not confidential' do
    let(:reference) { create(:reference, :feedback_provided, confidential: false) }

    it 'returns false' do
      expect(response).to have_http_status(:ok)
      references = parsed_response['data']['attributes']['references']
      expect(references.detect { |ref| ref['id'] == reference.id }['confidential']).to be(false)
    end
  end
end
