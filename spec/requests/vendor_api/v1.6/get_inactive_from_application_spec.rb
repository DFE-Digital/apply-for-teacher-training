require 'rails_helper'

RSpec.describe 'Vendor API - GET /api/v1.6/applications/:application_id' do
  include VendorAPISpecHelpers

  let(:application_form) { create(:completed_application_form) }
  let(:application_choice) { create_application_choice_for_currently_authenticated_provider(attributes) }
  let(:attributes) { { status:, application_form: } }

  before { get_api_request "/api/v1.6/applications/#{application_choice.id}" }

  context 'when the application choice is inactive' do
    let(:status) { :inactive }

    it 'returns true' do
      expect(response).to have_http_status(:ok)
      expect(parsed_response.dig('data', 'attributes', 'inactive')).to be(true)
    end
  end

  context 'when the application choice is not inactive' do
    %w[
      awaiting_provider_decision
      offer
      pending_conditions
      recruited
      rejected
      declined
      withdrawn
      conditions_not_met
      offer_deferred
    ].each do |status|
      context "when status is #{status}" do
        let(:status) { status }

        it 'returns false' do
          expect(response).to have_http_status(:ok)
          expect(parsed_response.dig('data', 'attributes', 'inactive')).to be(false)
        end
      end
    end
  end
end
