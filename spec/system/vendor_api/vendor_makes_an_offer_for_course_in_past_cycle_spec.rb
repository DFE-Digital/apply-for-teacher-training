require 'rails_helper'

RSpec.feature 'Vendor makes an offer for a course in the past recruitment cycle' do
  scenario 'A vendor makes an invalid offer' do
    given_a_candidate_has_submitted_their_application
    when_a_vendor_makes_an_offer_for_a_course_in_the_previous_cycle
    then_i_can_see_a_validation_error

    when_a_vendor_makes_an_offer_for_a_course_in_the_current_cycle
    then_the_offer_is_successful
  end

  def given_a_candidate_has_submitted_their_application
    @application_choice = create(:application_choice, :with_completed_application_form, :awaiting_provider_decision)
    @provider = @application_choice.provider
    @recruitment_cycle_year = RecruitmentCycle.previous_year
    @course = create(:course, recruitment_cycle_year: @recruitment_cycle_year, provider: @provider)
    @course_option = create(:course_option, course: @course)
  end

  def when_a_vendor_makes_an_offer_for_a_course_in_the_previous_cycle
    @api_token = VendorAPIToken.create_with_random_token!(provider: @provider)
    Capybara.current_session.driver.header('Authorization', "Bearer #{@api_token}")
    Capybara.current_session.driver.header('Content-Type', 'application/json')

    @provider_user = create(:provider_user, :with_notifications_enabled, providers: [@provider])
    uri = "/api/v1/applications/#{@application_choice.id}/offer"

    @api_response = page.driver.post(uri, offer_payload)

    # Unset session headers
    Capybara.current_session.driver.header('Authorization', nil)
    Capybara.current_session.driver.header('Content-Type', nil)
  end

  def then_i_can_see_a_validation_error
    parsed_response_body = JSON.parse(@api_response.body)
    validation_errors = parsed_response_body['errors']

    expect(@api_response.status).to eq 422
    expect(validation_errors.first['message']).to eq("Course must be in #{RecruitmentCycle.current_year} recruitment cycle")
  end

  def when_a_vendor_makes_an_offer_for_a_course_in_the_current_cycle
    @recruitment_cycle_year = RecruitmentCycle.current_year
    @course = create(:course, recruitment_cycle_year: @recruitment_cycle_year, provider: @provider)
    @course_option = create(:course_option, course: @course)

    Capybara.current_session.driver.header('Authorization', "Bearer #{@api_token}")
    Capybara.current_session.driver.header('Content-Type', 'application/json')

    @provider_user = create(:provider_user, :with_notifications_enabled, providers: [@provider])
    uri = "/api/v1/applications/#{@application_choice.id}/offer"

    @api_response = page.driver.post(uri, offer_payload)

    # Unset session headers
    Capybara.current_session.driver.header('Authorization', nil)
    Capybara.current_session.driver.header('Content-Type', nil)
  end

  def then_the_offer_is_successful
    parsed_response_body = JSON.parse(@api_response.body)
    expect(@api_response.status).to eq 200
    expect(parsed_response_body.dig('data', 'attributes', 'status')).to eq('offer')
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
        course: {
          recruitment_cycle_year: @recruitment_cycle_year,
          provider_code: @provider.code,
          course_code: @course.code,
          site_code: @course_option.site.code,
          study_mode: 'full_time',
        },
      },
    }.to_json
  end
end
