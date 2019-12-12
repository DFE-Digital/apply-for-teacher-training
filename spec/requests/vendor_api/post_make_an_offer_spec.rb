require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1/applications/:application_id/offer', type: :request do
  include VendorApiSpecHelpers
  include CourseOptionHelpers

  it_behaves_like 'an endpoint that requires metadata', '/offer'

  describe 'making an offer with specified conditions' do
    it 'returns the updated application' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )
      request_body = {
        "data": {
          "conditions": [
            'Completion of subject knowledge enhancement',
            'Completion of professional skills test',
          ],
        },
      }

      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: request_body

      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
      expect(parsed_response['data']['attributes']['status']).to eq('offer')
      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [
          'Completion of subject knowledge enhancement',
          'Completion of professional skills test',
        ],
      )
    end
  end

  describe 'making an offer for another course' do
    it 'returns the updated application' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      other_course_option = course_option_for_provider(provider: currently_authenticated_provider)

      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: {
        'data' => {
          'conditions' => [],
          'course' => {
            'provider_code' => other_course_option.course.provider.code,
            'course_code' => other_course_option.course.code,
            'site_code' => other_course_option.site.code,
          },
        },
      }

      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [],
        'course' => {
          'start_date' => other_course_option.course.start_date.iso8601,
          'provider_code' => other_course_option.course.provider.code,
          'course_code' => other_course_option.course.code,
          'site_code' => other_course_option.site.code,
          'study_mode' => 'full_time',
        },
      )
    end

    it 'returns an error when specifying a course from a different provider' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      other_course_option = course_option_for_provider(provider: create(:provider))

      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: {
        'data' => {
          'conditions' => [],
          'course' => {
            'provider_code' => other_course_option.course.provider.code,
            'course_code' => other_course_option.course.code,
            'site_code' => other_course_option.site.code,
          },
        },
      }

      expect(response).to have_http_status(422)
      expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
      expect(error_response['message']).to match 'Offered course does not belong to provider'
    end
  end

  describe 'offering for application with a decision' do
    it 'allows amending of existing offers' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )
      request_body = {
        "data": {
          "conditions": [
            'Completion of subject knowledge enhancement',
            'Completion of professional skills test',
          ],
        },
      }

      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: request_body

      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')

      request_body = {
        "data": {
          "conditions": [
            'Completion of subject knowledge enhancement',
            'Completion of professional skills test',
            'DBS Check',
          ],
        },
      }

      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: request_body

      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [
          'Completion of subject knowledge enhancement',
          'Completion of professional skills test',
          'DBS Check',
        ],
      )
    end

    it 'can change a rejection into an offer' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'rejected',
      )

      request_body = { "data": { "conditions": ['DBS Check'] } }
      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: request_body

      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
      expect(parsed_response['data']['attributes']['status']).to eq('offer')
    end
  end

  describe 'making an offer without specified conditions' do
    it 'returns the updated application' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )
      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: {
        "data": {
          "conditions": [],
        },
      }

      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
      expect(parsed_response['data']['attributes']['status']).to eq('offer')
      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [],
      )
    end
  end

  it 'returns an error when trying to transition to an invalid state' do
    application_choice = create_application_choice_for_currently_authenticated_provider(
      status: 'withdrawn',
    )

    post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: {}

    expect(response).to have_http_status(422)
    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
    expect(error_response['message']).to eq 'The application is not ready for that action'
  end

  it 'returns an error when given invalid conditions' do
    application_choice = create_application_choice_for_currently_authenticated_provider(
      status: 'awaiting_provider_decision',
    )

    post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: {
      data: {
        conditions: 'DO NOT WANT',
      },
    }

    expect(response).to have_http_status(422)
    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
    expect(error_response['message']).to eql 'Offer conditions must be an array'
  end

  it 'returns a not found error if the application can\'t be found' do
    request_body = {
                      "data": {
                        "conditions": [
                                  'Completion of subject knowledge enhancement',
                                  'Completion of professional skills test',
                        ],
                      },
                   }

    post_api_request '/api/v1/applications/non-existent-id/offer', params: request_body

    expect(response).to have_http_status(404)
    expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse')
    expect(error_response['message']).to eql('Could not find an application with ID non-existent-id')
  end
end
