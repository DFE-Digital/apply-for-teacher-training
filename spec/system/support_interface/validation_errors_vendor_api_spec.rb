require 'rails_helper'

RSpec.describe 'Validation errors Vendor API' do
  include DfESignInHelpers

  scenario 'Review validation errors' do
    given_i_am_a_support_user
    and_some_applications_exist
    and_vendor_api_requests_for_applications_have_been_made

    when_i_navigate_to_the_validation_errors_page
    then_i_see_a_list_of_error_groups

    when_i_click_on_a_group
    then_i_see_a_list_of_individual_errors

    when_i_click_on_link_in_breadcrumb_trail
    then_i_am_back_on_index_page
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_some_applications_exist
    @application_choice = create(:application_choice, :awaiting_provider_decision, :with_completed_application_form)
  end

  def and_vendor_api_requests_for_applications_have_been_made
    api_token = VendorAPIToken.create_with_random_token!(provider: @application_choice.provider)
    page.driver.header 'Authorization', "Bearer #{api_token}"

    visit '/api/v1/applications?since=2019-01-012222'
    visit '/api/v1/applications?since=2019-01-012222'
  end

  def when_i_navigate_to_the_validation_errors_page
    visit support_interface_path
    click_link_or_button 'Performance'
    click_link_or_button 'Validation errors'
    click_link_or_button 'Vendor API validation errors'
  end

  def then_i_see_a_list_of_error_groups
    expect(page).to have_content('/api/v1/applications: ParameterInvalid')
    expect(page).to have_content('2')
  end

  def when_i_click_on_a_group
    click_link_or_button('ParameterInvalid')
  end

  def then_i_see_a_list_of_individual_errors
    expect(page).to have_content('Showing errors on the ParameterInvalid field in /api/v1/applications by all providers')
    expect(page).to have_content('Query string: "since=2019-01-012222"')
    expect(page).to have_content('Request body: { "since": "2019-01-012222" }')
    expect(page).to have_content('/api/v1/applications: ParameterInvalid')
    expect(page).to have_content('Parameter is invalid (should be ISO8601): since')
  end

  def when_i_click_on_link_in_breadcrumb_trail
    click_link_or_button 'Vendor API'
  end

  def then_i_am_back_on_index_page
    expect(page).to have_current_path(support_interface_validation_errors_vendor_api_path)
  end
end
