require 'rails_helper'

RSpec.feature 'Tasks', sidekiq: false do
  include DfESignInHelpers

  scenario 'Support user performs a task' do
    given_i_am_a_support_user

    when_i_visit_the_support_tasks_page
    and_i_click_on_generate_test_applications
    then_i_see_that_the_job_has_been_scheduled

    and_when_i_click_on_generate_fake_provider
    then_i_see_new_providers_details_and_api_token
    and_i_am_able_to_connect_to_the_api_using_the_token
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_i_visit_the_support_tasks_page
    visit support_interface_tasks_path
  end

  def and_i_click_on_generate_test_applications
    click_link_or_button 'Generate test application'
  end

  def then_i_see_that_the_job_has_been_scheduled
    expect(page).to have_content 'Scheduled job to generate test applications'
  end

  def and_when_i_click_on_generate_fake_provider
    click_link_or_button 'Create a fake provider'
  end

  def then_i_see_new_providers_details_and_api_token
    expect(page).to have_content 'Provider name'
    expect(page).to have_content 'Provider code'
    expect(page).to have_content 'Vendor API token'
  end

  def and_i_am_able_to_connect_to_the_api_using_the_token
    api_token = find('.govuk-summary-list').all('.govuk-summary-list__value')[2].text
    page.driver.header 'Authorization', "Bearer #{api_token}"

    visit '/api/v1/ping'

    expect(page).to have_content('pong')
  end
end
