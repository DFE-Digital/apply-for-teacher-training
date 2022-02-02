require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1.1/applications/:application_id/confirm-deferred-offer', type: :request do
  include VendorAPISpecHelpers

  before do
    stub_const('VendorAPI::VERSION', '1.1')
  end

  let(:application_trait) { :with_deferred_offer }
  let(:request_body) { { data: { conditions_met: false } } }
  let!(:application_choice) do
    create(:submitted_application_choice,
           :with_completed_application_form,
           application_trait,
           course_option: original_course_option,
           current_course_option: original_course_option)
  end
  let(:original_course) do
    create(:course,
           :open_on_apply,
           :previous_year_but_still_available,
           provider: currently_authenticated_provider)
  end
  let(:original_course_option) do
    create(:course_option,
           :previous_year_but_still_available,
           course: original_course)
  end

  it_behaves_like 'an endpoint that requires metadata', '/confirm-deferred-offer', '1.1'

  describe 'request body' do
    context 'when valid' do
      let(:request_body) { { data: { conditions_met: false } } }

      it 'has conditions_met set' do
        expect(request_body[:data]).to be_valid_against_openapi_schema('ConfirmDeferredOffer', '1.1')
      end
    end

    context 'when invalid' do
      it 'when `data` is missing from the request_body it renders an error' do
        post_api_request "/api/v1.1/applications/#{application_choice.id}/confirm-deferred-offer", params: { data: {} }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to be_valid_against_openapi_schema('ParameterMissingResponse')
        expect(parsed_response['errors'].map { |error| error['message'] })
          .to contain_exactly('param is missing or the value is empty: data')
      end

      it 'when `conditions_met` is missing from the request_body it renders an error' do
        post_api_request "/api/v1.1/applications/#{application_choice.id}/confirm-deferred-offer", params: { data: { any_param: '' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to be_valid_against_openapi_schema('ParameterMissingResponse')
        expect(parsed_response['errors'].map { |error| error['message'] })
          .to contain_exactly('param is missing or the value is empty: conditions_met')
      end
    end
  end

  describe 'confirming a deffered offer' do
    context 'when the application is not in a state that allows offer deferal' do
      let(:application_trait) { :with_offer }

      it 'renders an Unprocessable Entity error' do
        post_api_request "/api/v1.1/applications/#{application_choice.id}/confirm-deferred-offer", params: request_body

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
        expect(parsed_response['errors'].map { |error| error['message'] })
          .to contain_exactly("It's not possible to perform this action while the application is in its current state")
      end
    end

    context 'when the offered course does not exist in the new cycle' do
      let(:original_course_option) { create(:course_option, course: original_course) }

      it 'renders an Unprocessable Entity error' do
        post_api_request "/api/v1.1/applications/#{application_choice.id}/confirm-deferred-offer", params: request_body

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
        expect(parsed_response['errors'].map { |error| error['message'] })
          .to contain_exactly('The offered course does not exist in this recruitment cycle')
      end
    end

    context 'when the offer requiring confirmation is in the current cycle' do
      let(:original_course) do
        create(:course,
               :open_on_apply,
               :available_in_current_and_next_year,
               provider: currently_authenticated_provider)
      end
      let(:original_course_option) do
        create(:course_option,
               :available_in_current_and_next_year,
               course: original_course)
      end

      it 'renders an Unprocessable Entity error' do
        post_api_request "/api/v1.1/applications/#{application_choice.id}/confirm-deferred-offer", params: request_body

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
        expect(parsed_response['errors'].map { |error| error['message'] })
          .to contain_exactly('Only applications deferred in the previous recruitment cycle can be confirmed')
      end
    end

    context 'when the application choice cannot be found for the authorised provider' do
      let(:application_choice) do
        create(:application_choice, :awaiting_provider_decision)
      end

      it 'renders a NotFound error' do
        post_api_request "/api/v1.1/applications/#{application_choice.id}/confirm-deferred-offer", params: request_body

        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse')
        expect(parsed_response['errors'].map { |error| error['error'] })
          .to contain_exactly('NotFound')
      end
    end

    describe 'when successful' do
      xit 'renders a SingleApplicationResponse' do
        post_api_request "/api/v1.1/applications/#{application_choice.id}/confirm-deferred-offer", params: request_body

        expect(response).to have_http_status(:ok)
        expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.1')
      end

      context 'when conditions_met is false' do
        let(:request_body) { { data: { conditions_met: false } } }

        it 'transitions the application to the pending_conditions state' do
          post_api_request "/api/v1.1/applications/#{application_choice.id}/confirm-deferred-offer", params: request_body

          expect(response).to have_http_status(:ok)
          expect(parsed_response['data']['attributes']['status']).to eq('pending_conditions')
        end
      end

      context 'when conditions_met is true' do
        let(:request_body) { { data: { conditions_met: true } } }

        it 'transitions the application to the recruited state' do
          post_api_request "/api/v1.1/applications/#{application_choice.id}/confirm-deferred-offer", params: request_body

          expect(response).to have_http_status(:ok)
          expect(parsed_response['data']['attributes']['status']).to eq('recruited')
        end
      end
    end
  end
end
