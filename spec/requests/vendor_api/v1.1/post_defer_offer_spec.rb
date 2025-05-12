require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1.1/applications/:application_id/defer-offer' do
  include VendorAPISpecHelpers

  it_behaves_like 'an endpoint that requires metadata', '/defer-offer', '1.1'

  describe 'deffering an offer' do
    let(:application_choice) do
      create_application_choice_for_currently_authenticated_provider(status: 'awaiting_provider_decision')
    end

    describe 'when the application is not in a state that allows offer deferal' do
      it 'renders an UnprocessableEntityResponse' do
        post_api_request "/api/v1.1/applications/#{application_choice.id}/defer-offer"

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response)
          .to contain_schema_with_error('UnprocessableEntityResponse',
                                        "It's not possible to perform this action while the application is in its current state",
                                        '1.1')
      end
    end

    describe 'when the application choice cannot be found for the authorised provider' do
      let(:application_choice) do
        create(:application_choice, :awaiting_provider_decision)
      end

      it 'renders a NotFoundResponse' do
        post_api_request "/api/v1.1/applications/#{application_choice.id}/defer-offer"

        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to contain_schema_with_error('NotFoundResponse',
                                                             'Unable to find Applications',
                                                             '1.1')
      end
    end

    describe 'when successful' do
      let(:course) { build(:course, provider: currently_authenticated_provider, recruitment_cycle_year: current_timetable.recruitment_cycle_year) }
      let(:course_option) { build(:course_option, course:) }
      let!(:application_choice) do
        create(:application_choice, :with_completed_application_form, :accepted, course_option:)
      end
      let(:original_status) { application_choice.status }

      it 'renders a SingleApplicationResponse' do
        post_api_request "/api/v1.1/applications/#{application_choice.id}/defer-offer"

        expect(response).to have_http_status(:ok)
        expect(parsed_response['data']['attributes']['offer'])
          .to include('status_before_deferral' => original_status,
                      'offer_deferred_at' => application_choice.reload.offer_deferred_at.iso8601,
                      'deferred_to_recruitment_cycle_year' => current_timetable.relative_next_year)

        expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.1')
      end
    end
  end
end
