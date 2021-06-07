require 'rails_helper'

RSpec.feature 'Vendor makes unconditional offer' do
  include CandidateHelper

  scenario 'A vendor makes an unconditional offer and this is accepted by the candidate' do
    FeatureFlag.activate(:unconditional_offers_via_api)

    given_a_candidate_has_submitted_their_application
    when_i_make_an_unconditional_offer_for_the_application_over_the_api
    then_i_can_see_the_offer_was_made_successfully

    when_the_candidate_accepts_the_unconditional_offer
    then_the_candidate_sees_that_they_have_accepted_the_offer
  end

  def given_a_candidate_has_submitted_their_application
    candidate_completes_application_form
    candidate_submits_application
  end

  def when_i_make_an_unconditional_offer_for_the_application_over_the_api
    api_token = VendorAPIToken.create_with_random_token!(provider: @provider)
    Capybara.current_session.driver.header('Authorization', "Bearer #{api_token}")
    Capybara.current_session.driver.header('Content-Type', 'application/json')

    @application_choice = @application.application_choices.first
    @course_option = @application_choice.course_option
    @provider_user = create(:provider_user, :with_notification_preferences_enabled, providers: [@provider])
    uri = "/api/v1/applications/#{@application_choice.id}/offer"

    @api_response = page.driver.post(uri, unconditional_offer_payload)

    # Unset session headers
    Capybara.current_session.driver.header('Authorization', nil)
    Capybara.current_session.driver.header('Content-Type', nil)
  end

  def then_i_can_see_the_offer_was_made_successfully
    parsed_response_body = JSON.parse(@api_response.body)
    application_attrs = parsed_response_body.dig('data', 'attributes')

    expect(@api_response.status).to eq 200
    expect(application_attrs['status']).to eq('offer')
    expect(application_attrs.dig('offer', 'conditions')).to eq([])
  end

  def when_the_candidate_accepts_the_unconditional_offer
    visit candidate_interface_offer_path(@application_choice)

    choose 'Accept offer'
    click_button 'Continue'

    click_button 'Accept offer'
  end

  def then_the_candidate_sees_that_they_have_accepted_the_offer
    expect(page).to have_content "You have accepted your offer for #{@application_choice.course.name_and_code} at #{@application_choice.provider.name}"
  end

  def unconditional_offer_payload
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
        conditions: [],
        course: nil,
      },
    }.to_json
  end
end
