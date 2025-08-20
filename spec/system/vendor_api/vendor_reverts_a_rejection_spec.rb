require 'rails_helper'

RSpec.describe 'Vendor reverts a rejection' do
  include CandidateHelper

  scenario 'A vendor reverts a rejection' do
    given_a_candidate_has_multiple_rejected_applications
    when_i_try_to_revert_the_rejection_on(@initial_application_choice)
    then_i_can_see_a_validation_error

    when_i_try_to_revert_the_rejection_on(@most_recent_application_choice)
    then_i_can_see_the_offer_was_made_successfully
  end

  def given_a_candidate_has_multiple_rejected_applications
    @initial_application_choice = create(:application_choice, :with_completed_application_form, :rejected)
    @most_recent_application_choice = build(:application_choice, :rejected, course_option: @initial_application_choice.course_option)
    create(:completed_application_form, candidate: @initial_application_choice.candidate, application_choices: [@most_recent_application_choice])
    @provider = @initial_application_choice.provider
  end

  def when_i_try_to_revert_the_rejection_on(application_choice)
    api_token = VendorAPIToken.create_with_random_token!(provider: @provider)
    Capybara.current_session.driver.header('Authorization', "Bearer #{api_token}")
    Capybara.current_session.driver.header('Content-Type', 'application/json')

    @provider_user = create(:provider_user, :with_notifications_enabled, providers: [@provider])
    uri = "/api/v1/applications/#{application_choice.id}/offer"

    @api_response = page.driver.post(uri, offer_payload)

    # Unset session headers
    Capybara.current_session.driver.header('Authorization', nil)
    Capybara.current_session.driver.header('Content-Type', nil)
  end

  def then_i_can_see_a_validation_error
    parsed_response_body = JSON.parse(@api_response.body)
    validation_errors = parsed_response_body['errors']

    expect(@api_response.status).to eq 422
    expect(validation_errors.first['message']).to eq('You cannot make an offer because you can only do so for the most recent application')
  end

  def then_i_can_see_the_offer_was_made_successfully
    parsed_response_body = JSON.parse(@api_response.body)
    application_attrs = parsed_response_body.dig('data', 'attributes')

    expect(@api_response.status).to eq 200
    expect(application_attrs['status']).to eq('offer')
  end

  def offer_payload
    {
      meta: {
        attribution: {
          full_name: 'Jane Smith',
          email: 'jane.smith@example.com',
          user_id: '12345',
        },
        timestamp: Time.zone.now.iso8601,
      },
      data: {
        conditions: ['Example condition'],
        course: nil,
      },
    }.to_json
  end
end
