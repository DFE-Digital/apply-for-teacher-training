require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1.0/applications/:application_id/offer' do
  include VendorAPISpecHelpers
  include CourseOptionHelpers

  it_behaves_like 'an endpoint that requires metadata', '/offer'

  describe 'making an offer with specified conditions' do
    it 'returns the updated application' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )
      request_body = {
        data: {
          conditions: [
            'Completion of subject knowledge enhancement',
            'Completion of professional skills test',
          ],
        },
      }
      expect(request_body[:data]).to be_valid_against_openapi_schema('MakeOffer', '1.0')

      post_api_request "/api/v1.0/applications/#{application_choice.id}/offer", params: request_body

      course_option = application_choice.course_option
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.0')
      expect(parsed_response['data']['attributes']['status']).to eq('offer')
      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [
          'Completion of subject knowledge enhancement',
          'Completion of professional skills test',
        ],
        'course' => course_option_to_course_payload(course_option),
        'offer_made_at' => application_choice.reload.offered_at.iso8601(3),
        'offer_accepted_at' => nil,
        'offer_declined_at' => nil,
      )
    end

    it 'logs the request as a VendorAPIRequest', :sidekiq do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )
      request_body = {
        data: {
          conditions: [
            'Completion of subject knowledge enhancement',
            'Completion of professional skills test',
          ],
        },
      }

      post_path = "/api/v1.0/applications/#{application_choice.id}/offer"

      expect {
        post_api_request post_path, params: request_body
      }.to change(VendorAPIRequest, :count)

      expect(VendorAPIRequest.first.request_path).to eq(post_path)
    end
  end

  describe 'making an offer with conditions with non UTF-8 characters' do
    it 'returns the updated application' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )
      request_body = {
        data: {
          conditions: [
            'Completion of subject knowledge enhancement°',
            'Completion of professional skills test',
          ],
        },
      }
      expect(request_body[:data]).to be_valid_against_openapi_schema('MakeOffer', '1.0')

      post_api_request "/api/v1.0/applications/#{application_choice.id}/offer", params: request_body

      course_option = application_choice.course_option
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.0')
      expect(parsed_response['data']['attributes']['status']).to eq('offer')
      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [
          'Completion of subject knowledge enhancement°',
          'Completion of professional skills test',
        ],
        'course' => course_option_to_course_payload(course_option),
        'offer_made_at' => application_choice.reload.offered_at.iso8601(3),
        'offer_accepted_at' => nil,
        'offer_declined_at' => nil,
      )
    end
  end

  describe 'making an offer for another course' do
    it 'returns the updated application' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      other_course_option = course_option_for_provider(provider: currently_authenticated_provider)

      post_api_request "/api/v1.0/applications/#{application_choice.id}/offer", params: {
        'data' => {
          'conditions' => [],
          'course' => course_option_to_course_payload(other_course_option),
        },
      }

      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.0')
      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [],
        'course' => course_option_to_course_payload(other_course_option),
        'offer_made_at' => application_choice.reload.offered_at.iso8601(3),
        'offer_accepted_at' => nil,
        'offer_declined_at' => nil,
      )
    end

    it 'returns an error when required attributes are missing' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      other_course_option = course_option_for_provider(provider: create(:provider))

      post_api_request "/api/v1.0/applications/#{application_choice.id}/offer", params: {
        'data' => {
          'conditions' => [],
          'course' => {
            'provider_code' => other_course_option.course.provider.code,
          },
        },
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse', '1.0')
      expect(parsed_response['errors'].map { |e| e['message'] }).to contain_exactly(
        'Course code cannot be blank',
        'Study mode cannot be blank',
        'Recruitment cycle year cannot be blank',
      )
    end

    it 'returns an error when specifying a course from a different provider' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      other_course_option = course_option_for_provider(provider: create(:provider))

      post_api_request "/api/v1.0/applications/#{application_choice.id}/offer", params: {
        'data' => {
          'conditions' => [],
          'course' => course_option_to_course_payload(other_course_option),
        },
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_response)
        .to contain_schema_with_error('UnprocessableEntityResponse',
                                      'The specified course is not associated with any of your organisations.')
    end

    it 'logs the actual error in a VendorAPIRequest when a 422 is returned', :sidekiq do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      other_course_option = course_option_for_provider(provider: create(:provider))

      expect {
        post_api_request "/api/v1.0/applications/#{application_choice.id}/offer", params: {
          'data' => {
            'conditions' => [],
            'course' => course_option_to_course_payload(other_course_option),
          },
        }
      }.to change(VendorAPIRequest, :count)

      expect(response).to have_http_status(:unprocessable_entity)

      logged_error = VendorAPIRequest.first.response_body['errors'].first['error']

      expect(logged_error).to eq('NotAuthorisedError')
    end

    it 'returns an error when specifying a provider that does not exist' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      post_api_request "/api/v1.0/applications/#{application_choice.id}/offer", params: {
        'data' => {
          'conditions' => [],
          'course' => {
            'recruitment_cycle_year' => current_year,
            'provider_code' => 'ABC',
            'course_code' => 'X100',
            'site_code' => 'E',
            'study_mode' => 'full_time',
          },
        },
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_response).to contain_schema_with_error('UnprocessableEntityResponse', 'Provider ABC does not exist')
    end

    it 'returns an error when specifying ambiguous course parameters' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      other_course_option = course_option_for_provider(provider: currently_authenticated_provider)

      course_option_for_provider(
        provider: currently_authenticated_provider,
        course: other_course_option.course,
      )

      course_payload = course_option_to_course_payload(other_course_option).except('site_code')

      post_api_request "/api/v1.0/applications/#{application_choice.id}/offer", params: {
        'data' => {
          'conditions' => [],
          'course' => course_payload,
        },
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_response)
        .to contain_schema_with_error('UnprocessableEntityResponse',
                                      "Found multiple full_time options for course #{course_payload['course_code']}")
    end

    it 'returns an error when trying to transition to an invalid state' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'withdrawn',
      )

      post_api_request "/api/v1.0/applications/#{application_choice.id}/offer", params: { data: { conditions: [] } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_response)
        .to contain_schema_with_error('UnprocessableEntityResponse',
                                      "It's not possible to perform this action while the application is in its current state")
    end

    it 'returns a NotFoundResponse if the application cannot be found' do
      request_body = {
        data: {
          conditions: [
            'Completion of subject knowledge enhancement',
            'Completion of professional skills test',
          ],
        },
      }

      post_api_request '/api/v1.0/applications/non-existent-id/offer', params: request_body

      expect(response).to have_http_status(:not_found)
      expect(parsed_response).to contain_schema_with_error('NotFoundResponse', 'Unable to find Applications')
    end

    it 'does not process the conditions if they are not provided correctly' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      other_course_option = course_option_for_provider(provider: currently_authenticated_provider)

      post_api_request "/api/v1.0/applications/#{application_choice.id}/offer", params: {
        data: {
          conditions: 'INVALID CONDITION FORMAT',
          'course' => course_option_to_course_payload(other_course_option).except(:start_date),
        },
      }

      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.0')
      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [],
        'course' => course_option_to_course_payload(other_course_option),
        'offer_made_at' => application_choice.reload.offered_at.iso8601(3),
        'offer_accepted_at' => nil,
        'offer_declined_at' => nil,
      )
    end

    it 'does not require the course start date to be specified' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      other_course_option = course_option_for_provider(provider: currently_authenticated_provider)

      post_api_request "/api/v1.0/applications/#{application_choice.id}/offer", params: {
        'data' => {
          'conditions' => [],
          'course' => course_option_to_course_payload(other_course_option).except(:start_date),
        },
      }

      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.0')
      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [],
        'course' => course_option_to_course_payload(other_course_option),
        'offer_made_at' => application_choice.reload.offered_at.iso8601(3),
        'offer_accepted_at' => nil,
        'offer_declined_at' => nil,
      )
    end
  end

  describe 'offering for application with a decision' do
    it 'allows amending of course_option and conditions for existing offers' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      request_body = {
        data: {
          conditions: [
            'DBS Check',
          ],
        },
      }

      post_api_request "/api/v1.0/applications/#{application_choice.id}/offer", params: request_body
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.0')

      new_course_option = course_option_for_provider(provider: currently_authenticated_provider)

      request_body = {
        data: {
          conditions: [
            'DBS Check',
            'Completion of subject knowledge enhancement',
            'Completion of professional skills test',
          ],
          course: course_option_to_course_payload(new_course_option),
        },
      }

      post_api_request "/api/v1.0/applications/#{application_choice.id}/offer", params: request_body

      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [
          'DBS Check',
          'Completion of subject knowledge enhancement',
          'Completion of professional skills test',
        ],
        'course' => course_option_to_course_payload(new_course_option),
        'offer_made_at' => application_choice.reload.offered_at.iso8601(3),
        'offer_accepted_at' => nil,
        'offer_declined_at' => nil,
      )
    end

    it 'can change a rejection into an offer' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'rejected',
      )

      request_body = { data: { conditions: ['DBS Check'] } }
      post_api_request "/api/v1.0/applications/#{application_choice.id}/offer", params: request_body

      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.0')
      expect(parsed_response['data']['attributes']['status']).to eq('offer')
    end
  end

  describe 'making an offer without specified conditions' do
    it 'returns the updated application' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      post_api_request "/api/v1.0/applications/#{application_choice.id}/offer", params: {
        data: {
          conditions: [],
        },
      }

      course_option = application_choice.course_option
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.0')
      expect(parsed_response['data']['attributes']['status']).to eq('offer')
      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [],
        'course' => course_option_to_course_payload(course_option),
        'offer_made_at' => application_choice.reload.offered_at.iso8601(3),
        'offer_accepted_at' => nil,
        'offer_declined_at' => nil,
      )
    end
  end

  describe 'changing offers' do
    it 'can change the offer conditions' do
      choice = create(:application_choice,
                      :with_completed_application_form,
                      :offered,
                      course_option: course_option_for_provider(provider: currently_authenticated_provider))

      request_body = {
        data: {
          conditions: [
            'Change your sheets',
            'Wash your clothes',
          ],
        },
      }

      post_api_request "/api/v1.0/applications/#{choice.id}/offer", params: request_body

      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [
          'Change your sheets',
          'Wash your clothes',
        ],
        'course' => course_option_to_course_payload(choice.course_option),
        'offer_made_at' => choice.reload.offered_at.iso8601(3),
        'offer_accepted_at' => nil,
        'offer_declined_at' => nil,
      )
      expect(choice.offer.reload.all_conditions_text).to eq(['Change your sheets', 'Wash your clothes'])
    end

    it 'returns 200 OK when sending the same offer & conditions repeatedly' do
      choice = create(:application_choice,
                      :with_completed_application_form,
                      :offered,
                      course_option: course_option_for_provider(provider: currently_authenticated_provider))

      request_body = {
        data: {
          conditions: choice.offer.all_conditions_text,
          course: course_option_to_course_payload(choice.course_option),
        },
      }

      expect {
        post_api_request "/api/v1.0/applications/#{choice.id}/offer", params: request_body
      }.not_to(change { choice.reload })

      expect(response).to have_http_status(:ok)
    end
  end

  context 'making an offer to an application from a previous cycle', time: after_apply_deadline do
    it 'returns an error' do
      application_choice = create_application_choice_for_currently_authenticated_provider(status: 'rejected')
      advance_time_to(after_find_opens(next_year))

      request_body = { data: { conditions: ['DBS Check'] } }

      post_api_request "/api/v1.0/applications/#{application_choice.id}/offer", params: request_body

      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_response)
        .to contain_schema_with_error('UnprocessableEntityResponse',
                                      "Course must be in #{current_year} recruitment cycle")
    end
  end

  def course_option_to_course_payload(course_option)
    {
      'recruitment_cycle_year' => course_option.course.recruitment_cycle_year,
      'provider_code' => course_option.course.provider.code,
      'course_code' => course_option.course.code,
      'site_code' => course_option.site.code,
      'study_mode' => course_option.study_mode,
      'start_date' => course_option.course.start_date.strftime('%Y-%m'),
    }
  end
end
