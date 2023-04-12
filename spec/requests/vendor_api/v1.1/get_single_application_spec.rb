require 'rails_helper'

RSpec.describe 'Vendor API - GET /api/v1.1/applications/:application_id' do
  include VendorAPISpecHelpers
  include CourseOptionHelpers

  let(:pending_reference) { create(:reference, :feedback_requested) }
  let(:application_form) do
    create(
      :completed_application_form,
      application_references: [
        pending_reference,
        create(
          :reference,
          :feedback_provided,
          safeguarding_concerns: 'Concerned',
          safeguarding_concerns_status: 'has_safeguarding_concerns_to_declare',
        ),
      ],
    )
  end

  it 'returns a response that is valid according to the OpenAPI schema' do
    application_choice = create_application_choice_for_currently_authenticated_provider(
      status: 'awaiting_provider_decision',
    )

    get_api_request "/api/v1.1/applications/#{application_choice.id}"

    expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.1')
  end

  it 'includes an interviews section' do
    application_choice = create_application_choice_for_currently_authenticated_provider(
      status: 'awaiting_provider_decision',
    )

    get_api_request "/api/v1.1/applications/#{application_choice.id}"

    expect(response).to have_http_status(:ok)
    expect(parsed_response['data']['attributes']['interviews']).not_to be_nil
  end

  context 'when the candidate has not accepted an offer' do
    it 'returns an empty references object' do
      attributes = { status: 'awaiting_provider_decision', application_form: application_form }
      application_choice = create_application_choice_for_currently_authenticated_provider(attributes)

      get_api_request "/api/v1.1/applications/#{application_choice.id}"

      expect(response).to have_http_status(:ok)
      references = parsed_response['data']['attributes']['references']
      expect(references).to eq []
    end
  end

  context 'when a candidate has accepted an offer' do
    it 'surfaces any references with provided feedback' do
      attributes = { status: 'pending_conditions', application_form: application_form }
      application_choice = create_application_choice_for_currently_authenticated_provider(attributes)

      get_api_request "/api/v1.1/applications/#{application_choice.id}"

      expect(response).to have_http_status(:ok)
      references = parsed_response['data']['attributes']['references']
      expect(references.pluck('reference').join.empty?).to be(false)
      expect(references.pluck('safeguarding_concerns').any?).to be(true)
      expect(references.pluck('id')).not_to include pending_reference.id
    end

    it 'surfaces any offer conditions' do
      FeatureFlag.activate(:provider_ske)

      attributes = { status: 'pending_conditions', application_form: application_form }
      application_choice = create_application_choice_for_currently_authenticated_provider(attributes)

      offer = create(:offer, :with_ske_conditions, application_choice:)

      get_api_request "/api/v1.1/applications/#{application_choice.id}"

      expect(response).to have_http_status(:ok)
      offer_response = parsed_response['data']['attributes']['offer']
      expect(offer_response['conditions']).to contain_exactly(
        offer.conditions.first.text,
        'Mathematics subject knowledge enhancement course',
      )
    end
  end
end
