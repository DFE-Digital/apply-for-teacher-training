require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1.1/applications/:application_id/confirm-deferred-offer' do
  include VendorAPISpecHelpers

  let(:application_trait) { :offer_deferred }
  let(:request_body) { { data: { conditions_met: false } } }
  let!(:application_choice) do
    create(:application_choice, :awaiting_provider_decision,
           :with_completed_application_form,
           application_trait,
           course_option: original_course_option,
           current_course_option: original_course_option)
  end
  let(:original_course) do
    create(:course,
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
        expect(parsed_response).to contain_schema_with_error('ParameterMissingResponse',
                                                             'param is missing or the value is empty or invalid: data',
                                                             '1.1')
      end

      it 'when `conditions_met` is missing from the request_body it renders an error' do
        post_api_request "/api/v1.1/applications/#{application_choice.id}/confirm-deferred-offer", params: { data: { any_param: '' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to contain_schema_with_error('ParameterMissingResponse',
                                                             'param is missing or the value is empty or invalid: conditions_met',
                                                             '1.1')
      end
    end
  end

  describe 'confirming a deffered offer' do
    context 'when the application is not in a state that allows offer deferal' do
      let(:application_trait) { :offered }

      it 'renders an UnprocessableEntityResponse' do
        post_api_request "/api/v1.1/applications/#{application_choice.id}/confirm-deferred-offer", params: request_body

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to contain_schema_with_error('UnprocessableEntityResponse',
                                                             "It's not possible to perform this action while the application is in its current state",
                                                             '1.1')
      end
    end

    context 'when the offered course does not exist in the new cycle' do
      let(:original_course_option) { create(:course_option, course: original_course) }

      it 'renders an UnprocessableEntityResponse' do
        post_api_request "/api/v1.1/applications/#{application_choice.id}/confirm-deferred-offer", params: request_body

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to contain_schema_with_error('UnprocessableEntityResponse',
                                                             'The offered course does not exist in this recruitment cycle',
                                                             '1.1')
      end
    end

    context 'when the offer requiring confirmation is in the current cycle' do
      let(:original_course) do
        create(:course,
               :available_in_current_and_next_year,
               provider: currently_authenticated_provider)
      end
      let(:original_course_option) do
        create(:course_option,
               :available_in_current_and_next_year,
               course: original_course)
      end

      it 'renders an UnprocessableEntityResponse' do
        post_api_request "/api/v1.1/applications/#{application_choice.id}/confirm-deferred-offer", params: request_body

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to contain_schema_with_error('UnprocessableEntityResponse',
                                                             'Only applications deferred in the previous recruitment cycle can be confirmed',
                                                             '1.1')
      end
    end

    context 'when the application choice cannot be found for the authorised provider' do
      let(:application_choice) do
        create(:application_choice, :awaiting_provider_decision)
      end

      it 'renders a NotFoundResponse' do
        post_api_request "/api/v1.1/applications/#{application_choice.id}/confirm-deferred-offer", params: request_body

        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to contain_schema_with_error('NotFoundResponse', 'Unable to find Applications', '1.1')
      end
    end

    describe 'when successful' do
      it 'renders a SingleApplicationResponse' do
        post_api_request "/api/v1.1/applications/#{application_choice.id}/confirm-deferred-offer", params: request_body

        expect(response).to have_http_status(:ok)
        expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.1')
      end

      it 'unsets the `deferred_to_recruitment_cycle_year`' do
        post_api_request "/api/v1.1/applications/#{application_choice.id}/confirm-deferred-offer", params: request_body

        expect(response).to have_http_status(:ok)
        expect(parsed_response['data']['attributes']['offer']['deferred_to_recruitment_cycle_year']).to be_nil
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

  context 'when valid optional course attributes are provided' do
    let(:new_course) do
      create(:course,
             :available_in_current_and_next_year,
             provider: currently_authenticated_provider)
    end
    let(:new_course_option) do
      create(:course_option,
             :available_in_current_and_next_year,
             course: new_course)
    end
    let(:request_body) do
      {
        data: {
          conditions_met: false,
          course: {
            recruitment_cycle_year: new_course.recruitment_cycle_year,
            provider_code: new_course.provider.code,
            course_code: new_course.code,
            site_code: new_course_option.site.code,
            study_mode: new_course_option.study_mode,
          },
        },
      }
    end

    it 'confirms the deferral using the new course details' do
      post_api_request "/api/v1.1/applications/#{application_choice.id}/confirm-deferred-offer", params: request_body

      expect(response).to have_http_status(:ok)
      expect(application_choice.reload.current_course_option).to eq(new_course_option)
      expect(parsed_response['data']['attributes']['status']).to eq('pending_conditions')
    end
  end

  context 'when invalid optional course attributes are provided' do
    let(:request_body) do
      {
        data: {
          conditions_met: true,
          course: {
            recruitment_cycle_year: 2099,
            provider_code: 'X00',
            course_code: 'NONE',
            site_code: 'NONE',
            study_mode: 'full_time',
          },
        },
      }
    end

    it 'returns a NotFoundResponse with an appropriate error message' do
      post_api_request "/api/v1.1/applications/#{application_choice.id}/confirm-deferred-offer", params: request_body

      expect(response).to have_http_status(:not_found)
      expect(parsed_response).to contain_schema_with_error(
        'NotFoundResponse',
        'Unable to find CourseOptions',
        '1.1',
      )
    end
  end

  context 'when valid optional course attributes are provided without a site_code' do
    let(:new_course) do
      create(:course,
             :available_in_current_and_next_year,
             provider: currently_authenticated_provider)
    end
    let(:new_course_option) do
      create(:course_option,
             :available_in_current_and_next_year,
             course: new_course)
    end
    let(:request_body) do
      {
        data: {
          conditions_met: false,
          course: {
            recruitment_cycle_year: new_course.recruitment_cycle_year,
            provider_code: new_course.provider.code,
            course_code: new_course.code,
            study_mode: new_course_option.study_mode,
            start_date: '2005-09',
          },
        },
      }
    end

    it 'still confirms the deferral using the new course details' do
      post_api_request "/api/v1.1/applications/#{application_choice.id}/confirm-deferred-offer", params: request_body

      expect(response).to have_http_status(:ok)
      expect(application_choice.reload.current_course_option).to eq(new_course_option)
      expect(parsed_response['data']['attributes']['status']).to eq('pending_conditions')
    end
  end

  context 'when some mandatory parameters are missing' do
    let(:new_course) do
      create(:course,
             :available_in_current_and_next_year,
             provider: currently_authenticated_provider)
    end
    let(:new_course_option) do
      create(:course_option,
             :available_in_current_and_next_year,
             course: new_course)
    end
    let(:request_body) do
      {
        data: {
          conditions_met: false,
          course: {
            recruitment_cycle_year: new_course.recruitment_cycle_year,
            course_code: new_course.code,
          },
        },
      }
    end

    it 'returns a NotFoundResponse' do
      post_api_request "/api/v1.1/applications/#{application_choice.id}/confirm-deferred-offer", params: request_body

      expect(response).to have_http_status(:not_found)
      expect(parsed_response).to contain_schema_with_error(
        'NotFoundResponse',
        'Unable to find CourseOptions',
        '1.1',
      )
    end
  end
end
