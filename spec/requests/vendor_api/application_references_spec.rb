require 'rails_helper'

RSpec.describe 'Vendor API application references' do
  include VendorAPISpecHelpers

  let(:application_choice) do
    create_application_choice_for_currently_authenticated_provider({}, traits)
  end
  let(:returned_references) { parsed_response.dig('data', 'attributes', 'references') }
  let(:returned_reference) { returned_references.first&.deep_symbolize_keys }

  let(:reference) { application_choice.application_form.application_references.creation_order.first }
  let!(:unsent_reference) { application_choice.application_form.application_references.creation_order.second.update(feedback_status: 'not_requested_yet') }

  before do
    get_api_request "/api/v#{version}/applications/#{application_choice.id}"
  end

  context 'when the offer is accepted' do
    let(:traits) { %i[accepted] }

    %w[1.0 1.1 1.2].each do |api_version|
      context "for version #{api_version}" do
        let(:version) { api_version }

        it 'returns the full application references' do
          expect(returned_reference).to eq(
            id: reference.id,
            name: reference.name,
            email: reference.email_address,
            relationship: reference.relationship,
            reference: reference.feedback,
            referee_type: reference.referee_type,
            safeguarding_concerns: reference.has_safeguarding_concerns_to_declare?,
          )
        end

        it 'does not return the reference status' do
          expect(returned_reference).not_to have_key(:reference_received)
        end
      end
    end

    context 'for version 1.3' do
      let(:version) { '1.3' }

      context 'when the reference request has not been sent' do
        let(:returned_reference) { returned_references.second&.deep_symbolize_keys }

        it 'does not return the reference' do
          expect(returned_reference).to be_nil
        end
      end

      context 'when the reference request has been sent' do
        it 'returns the full application references with the reference status' do
          expect(returned_reference).to eq(
            id: reference.id,
            name: reference.name,
            email: reference.email_address,
            relationship: reference.relationship,
            reference: reference.feedback,
            referee_type: reference.referee_type,
            safeguarding_concerns: reference.has_safeguarding_concerns_to_declare?,
            reference_received: true,
          )
        end
      end
    end
  end

  context 'when the offer is not yet accepted' do
    let(:traits) { %i[offered] }

    %w[1.0 1.1 1.2].each do |api_version|
      context "for version #{api_version}" do
        let(:version) { api_version }

        it 'returns empty references' do
          expect(returned_references).to eq([])
        end
      end
    end

    context 'for version 1.3' do
      let(:version) { '1.3' }

      it 'returns referee details' do
        expect(returned_reference).to include(
          id: reference.id,
          name: reference.name,
          email: reference.email_address,
          relationship: reference.relationship,
          referee_type: reference.referee_type,
        )
      end

      it 'returns the reference status' do
        expect(returned_reference).to include(reference_received: false)
      end

      it 'does not return reference feedback' do
        expect(returned_reference).to include(reference: nil)
      end

      it 'does not return safeguarding concerns' do
        expect(returned_reference).to include(safeguarding_concerns: nil)
      end
    end
  end
end
