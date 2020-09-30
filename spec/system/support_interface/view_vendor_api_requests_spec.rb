require 'rails_helper'

RSpec.feature 'Vendor API Requests' do
  include DfESignInHelpers

  scenario 'API requests are logged' do
    FeatureFlag.activate(:vendor_api_request_tracing)

    given_i_am_a_support_user
    and_some_applications_exist
    and_vendor_api_requests_for_applications_have_been_made

    when_i_visit_the_vendor_api_requests_page
    then_i_see_the_api_request
    and_i_see_the_status_of_the_request

    when_i_click_on_details_of_the_request
    then_i_see_the_request_and_response_info

    when_i_search_for_a_specific_request_path
    then_i_only_see_api_requests_filtered_by_the_search

    when_i_filter_by_status
    then_i_only_see_api_requests_filtered_by_status
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_some_applications_exist
    applications = create_list(:submitted_application_choice, 2)
    @first_application_choice = applications.first
    @last_application_choice = applications.last
  end

  def and_vendor_api_requests_for_applications_have_been_made
    visit vendor_api_path(@first_application_choice)

    provider = @last_application_choice.provider
    unhashed_token, hashed_token = Devise.token_generator.generate(VendorAPIToken, :hashed_token)
    create(:vendor_api_token, hashed_token: hashed_token, provider_id: provider.id)

    Capybara.current_session.driver.header('Authorization', "Bearer #{unhashed_token}")

    visit vendor_api_path(@last_application_choice)

    Capybara.current_session.driver.header('Authorization', nil)
  end

  def when_i_visit_the_vendor_api_requests_page
    visit support_interface_vendor_api_requests_path
  end

  def then_i_see_the_api_request
    expect(page).to have_content(vendor_api_path(@first_application_choice))
    expect(page).to have_content(vendor_api_path(@last_application_choice))
  end

  def and_i_see_the_status_of_the_request
    expect(page).to have_content('401')
    expect(page).to have_content('200')
  end

  def when_i_click_on_details_of_the_request
    find('.govuk-details__summary-text', match: :first).click
  end

  def then_i_see_the_request_and_response_info
    expect(page).to have_content('Headers')
    expect(page).to have_content('HTTP_HOST')
    expect(page).to have_content('Request params')
    expect(page).to have_content('Response body')
    expect(page).to have_content('Unauthorized')
  end

  def when_i_search_for_a_specific_request_path
    fill_in :q, with: "applications/#{@first_application_choice.id}"
    click_on 'Apply filters'
  end

  def then_i_only_see_api_requests_filtered_by_the_search
    expect(page).to have_content(vendor_api_path(@first_application_choice))
    expect(page).not_to have_content(vendor_api_path(@last_application_choice))
  end

  def when_i_filter_by_status
    fill_in :q, with: ''
    check '200'
    click_on 'Apply filters'
  end

  def then_i_only_see_api_requests_filtered_by_status
    expect(page).not_to have_content(vendor_api_path(@first_application_choice))
    expect(page).to have_content(vendor_api_path(@last_application_choice))
  end
end
