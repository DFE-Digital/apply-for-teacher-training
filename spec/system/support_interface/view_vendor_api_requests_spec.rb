require 'rails_helper'

RSpec.describe 'Vendor API Requests' do
  include DfESignInHelpers

  scenario 'Listed requests are filtered' do
    given_i_am_a_support_user
    and_some_applications_exist
    and_vendor_api_requests_for_applications_have_been_made

    when_i_visit_the_vendor_api_requests_page
    then_i_see_that_i_must_filter_by_provider_code

    when_i_filter_by_provider
    then_i_only_see_api_requests_filtered_by_provider

    when_i_click_on_details_of_the_get_request
    then_i_see_the_get_request_and_response_info

    when_i_click_on_details_of_the_post_request
    then_i_see_the_post_request_and_response_info

    when_i_click_on_details_of_the_validation_error_request
    then_i_see_the_validation_error_request_and_response_info

    when_i_filter_by_status_200
    then_i_see_the_provider_get_request
    and_i_see_the_provider_post_request
    and_i_do_not_see_the_provider_validation_error_request

    when_i_clear_filters
    then_i_see_that_i_must_filter_by_provider_code

    when_i_filter_by_provider
    and_i_filter_by_request_method
    then_i_see_the_provider_get_request
    and_i_see_the_provider_validation_error_request
    and_i_do_not_see_the_provider_post_request

    when_i_clear_filters
    then_i_see_that_i_must_filter_by_provider_code

    when_i_filter_by_provider
    and_i_search_for_a_specific_request_path
    then_i_see_the_provider_post_request
    and_i_do_not_see_the_provider_get_request
    and_i_do_not_see_the_provider_validation_error_request

    when_i_clear_filters
    then_i_see_that_i_must_filter_by_provider_code

    when_i_filter_by_an_invalid_provider_code
    then_i_see_there_are_no_results
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_some_applications_exist
    applications = create_list(:application_choice, 2, :with_completed_application_form)
    @first_application_choice = applications.first
    @last_application_choice = applications.last
  end

  def and_vendor_api_requests_for_applications_have_been_made
    visit vendor_api_path('v1', @first_application_choice)
    @unvalidated_request = VendorAPIRequest.last

    @validated_provider = @last_application_choice.provider
    unhashed_token, hashed_token = Devise.token_generator.generate(VendorAPIToken, :hashed_token)
    create(:vendor_api_token, hashed_token:, provider_id: @validated_provider.id)

    Capybara.current_session.driver.header('Authorization', "Bearer #{unhashed_token}")

    visit vendor_api_path('v1', @last_application_choice)
    @validated_request = VendorAPIRequest.last

    Capybara.current_session.driver.header('Authorization', nil)

    @post_api_request = create(
      :vendor_api_request,
      request_method: 'POST',
      request_body: { data: { 'foo' => 'bar' } },
      request_path: '/api/v1/applications/9999/offer',
      provider: @validated_provider,
    )

    @validation_error_request = create(
      :vendor_api_request,
      :with_validation_error,
      provider: @validated_provider,
    )

    @random_api_request = create(:vendor_api_request)
  end

  def when_i_visit_the_vendor_api_requests_page
    visit support_interface_vendor_api_requests_path
  end

  def then_i_see_the_api_request
    expect(page).to have_css('p.govuk-body', exact_text: '/api/v1/applications/9999/offer')
    expect(page).to have_css('p.govuk-body', exact_text: vendor_api_path('v1', @first_application_choice))
    expect(page).to have_css('p.govuk-body', exact_text: vendor_api_path('v1', @last_application_choice))
  end

  def and_i_see_the_status_of_the_request
    expect(page).to have_content('401')
    expect(page).to have_content('200')
  end

  def when_i_click_on_details_of_the_post_request
    within("#vender-api-request-#{@post_api_request.id}") do
      first('.govuk-details__summary-text').click
    end
  end

  def when_i_click_on_details_of_the_get_request
    within("#vender-api-request-#{@validated_request.id}") do
      page.find('.govuk-details__summary-text').click
    end
  end

  def when_i_click_on_details_of_the_validation_error_request
    within("#vender-api-request-#{@validation_error_request.id}") do
      page.find('.govuk-details__summary-text').click
    end
  end

  def then_i_see_the_get_request_and_response_info
    within("#vender-api-request-#{@validated_request.id}") do
      expect(page).to have_element(:dt, text: 'Status', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: '200', class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Method', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: 'GET', class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Path', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: @validated_request.request_path, class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Provider', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: @validated_provider.name, class: 'govuk-summary-list__value')

      within('.govuk-details__text') do
        expect(page).to have_element(:h3, text: 'Headers')
        expect(page).to have_element(:h3, text: 'Response headers')
      end
    end
  end

  def then_i_see_the_post_request_and_response_info
    within("#vender-api-request-#{@post_api_request.id}") do
      expect(page).to have_element(:dt, text: 'Status', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: '200', class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Method', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: 'POST', class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Path', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: @post_api_request.request_path, class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Provider', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: @validated_provider.name, class: 'govuk-summary-list__value')

      within('.govuk-details__text') do
        expect(page).to have_element(:h3, text: 'Headers')
        expect(page).to have_element(:h3, text: 'Request body')
      end
    end
  end

  def then_i_see_the_validation_error_request_and_response_info
    within("#vender-api-request-#{@validation_error_request.id}") do
      expect(page).to have_element(:dt, text: 'Status', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: '422', class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Method', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: 'GET', class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Path', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: @validation_error_request.request_path, class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Provider', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: @validated_provider.name, class: 'govuk-summary-list__value')

      within('.govuk-details__text') do
        expect(page).to have_element(:h3, text: 'Headers')
        expect(page).to have_element(:h3, text: 'Response body')
        expect(page).to have_content('errors')
        expect(page).to have_content('ValidationError')
        expect(page).to have_content('Some error message')
      end
    end
  end

  def when_i_filter_by_status_200
    check '200'
    click_link_or_button 'Apply filters'
  end

  def then_i_only_see_api_requests_filtered_by_status
    expect(page).to have_no_css('p.govuk-body', exact_text: vendor_api_path('v1', @first_application_choice))
    expect(page).to have_css('p.govuk-body', exact_text: vendor_api_path('v1', @last_application_choice))
    expect(page).to have_css('p.govuk-body', exact_text: '/api/v1/applications/9999/offer')
  end

  def and_i_clear_filters
    click_link_or_button 'Clear filters'
  end
  alias_method :when_i_clear_filters, :and_i_clear_filters

  def and_i_filter_by_request_method
    check 'GET'
    click_link_or_button 'Apply filters'
  end

  def then_i_see_api_requests_filtered_by_request_method
    expect(page).to have_css('p.govuk-body', exact_text: vendor_api_path('v1', @first_application_choice))
    expect(page).to have_css('p.govuk-body', exact_text: vendor_api_path('v1', @last_application_choice))
    expect(page).to have_no_css('p.govuk-body', exact_text: '/api/v1/applications/9999/offer')
  end

  def and_i_search_for_a_specific_request_path
    fill_in :q, with: @post_api_request.request_path
    click_link_or_button 'Apply filters'
  end

  def then_i_only_see_api_requests_filtered_by_the_search
    expect(page).to have_css('p.govuk-body', exact_text: vendor_api_path('v1', @first_application_choice))
    expect(page).to have_no_css('p.govuk-body', exact_text: vendor_api_path('v1', @last_application_choice))
  end

  def when_i_filter_by_provider
    fill_in 'Provider code', with: @validated_provider.code
    click_link_or_button 'Apply filters'
  end

  def then_i_only_see_api_requests_filtered_by_provider
    expect(page).to have_css("#vender-api-request-#{@post_api_request.id}")
    expect(page).to have_css("#vender-api-request-#{@validated_request.id}")
    expect(page).to have_css("#vender-api-request-#{@validation_error_request.id}")

    expect(page).to have_no_css("#vender-api-request-#{@random_api_request.id}")
    expect(page).to have_no_css("#vender-api-request-#{@unvalidated_request.id}")
  end

  def then_i_see_the_provider_get_request
    expect(page).to have_css("#vender-api-request-#{@validated_request.id}")
  end

  def and_i_see_the_provider_post_request
    expect(page).to have_css("#vender-api-request-#{@post_api_request.id}")
  end
  alias_method :then_i_see_the_provider_post_request, :and_i_see_the_provider_post_request

  def and_i_do_not_see_the_provider_validation_error_request
    expect(page).to have_no_css("#vender-api-request-#{@validation_error_request.id}")
  end

  def and_i_see_the_provider_validation_error_request
    expect(page).to have_css("#vender-api-request-#{@validation_error_request.id}")
  end

  def and_i_do_not_see_the_provider_post_request
    expect(page).to have_no_css("#vender-api-request-#{@post_api_request.id}")
  end

  def and_i_do_not_see_the_provider_get_request
    expect(page).to have_no_css("#vender-api-request-#{@validated_request.id}")
  end

  def then_i_see_that_i_must_filter_by_provider_code
    expect(page).to have_element(:p, text: 'Select filters to search for vendor API requests.', class: 'govuk-body')
    expect(page).to have_element(:p, text: 'You must enter a provider code as part of your search.', class: 'govuk-body')
  end

  def when_i_filter_by_an_invalid_provider_code
    fill_in 'Provider code', with: 'INVALID'
    click_link_or_button 'Apply filters'
  end

  def then_i_see_there_are_no_results
    expect(page).to have_element(:p, text: 'There are no vender API requests found for the selected filters.')
    expect(page).to have_element(:p, text: 'Try changing the selected filters.')
  end
end
