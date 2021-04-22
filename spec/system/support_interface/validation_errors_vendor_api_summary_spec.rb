require 'rails_helper'

RSpec.feature 'Validation errors Vendor API summary' do
  include DfESignInHelpers

  scenario 'Review validation error summary' do
    given_i_am_a_support_user
    and_some_applications_exist
    and_vendor_api_requests_for_applications_have_been_made

    when_i_navigate_to_the_validation_errors_summary_page
    then_i_should_see_numbers_for_the_past_week_month_and_all_time

    when_i_click_on_link_to_the_applications_request_errors
    then_i_should_see_errors_for_the_applications_request_only
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_some_applications_exist
    @application_choice = create(:submitted_application_choice, :with_completed_application_form)
  end

  def and_vendor_api_requests_for_applications_have_been_made
    api_token = VendorAPIToken.create_with_random_token!(provider: @application_choice.provider)
    page.driver.header 'Authorization', "Bearer #{api_token}"

    visit '/api/v1/applications?since=2019-01-012222'
    visit '/api/v1/applications?since=2019-01-012222'
  end

  def when_i_navigate_to_the_validation_errors_summary_page
    visit support_interface_path
    click_link 'Performance'
    click_link 'Validation errors'
    click_link 'Vendor API validation errors'
    click_link 'Validation error summary'
  end

  def then_i_should_see_numbers_for_the_past_week_month_and_all_time
    expect(find('table').all('tr')[2].text).to eq '/api/v1/applications ParameterInvalid 2 1 2 1 2 1'
  end

  def when_i_click_on_link_to_the_applications_request_errors
    click_link '/api/v1/applications'
  end

  def then_i_should_see_errors_for_the_applications_request_only
    expect(page).to have_current_path(
      support_interface_validation_errors_vendor_api_search_path(request_path: '/api/v1/applications'),
    )
  end
end
