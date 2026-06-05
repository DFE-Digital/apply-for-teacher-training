require 'rails_helper'

RSpec.describe 'Viewing tasks page in support' do
  include DfESignInHelpers

  context 'production' do
    around do |example|
      ClimateControl.modify(HOSTING_ENVIRONMENT_NAME: 'production') { example.run }
    end

    scenario 'Support user cannot view tasks page in production' do
      given_i_am_signed_in_as_a_support_user
      and_i_click_on('Settings')
      then_i_do_not_see_tasks_in_the_menu
      and_i_visit_the_tasks_page
      then_i_see_404_error
    end
  end

  context 'qa' do
    around do |example|
      ClimateControl.modify(HOSTING_ENVIRONMENT_NAME: 'qa') { example.run }
    end

    scenario 'Support user can view tasks page in qa' do
      given_i_am_signed_in_as_a_support_user
      and_i_click_on('Settings')
      and_i_click_on('Tasks')
      then_i_see_tasks_content
    end
  end

  context 'sandbox' do
    around do |example|
      ClimateControl.modify(HOSTING_ENVIRONMENT_NAME: 'sandbox', SANDBOX: 'true') { example.run }
    end

    scenario 'Support user can view tasks page in sandbox' do
      given_i_am_signed_in_as_a_support_user
      and_i_click_on('Settings')
      and_i_click_on('Tasks')
      then_i_see_sandbox_tasks_content
    end
  end

private

  def then_i_do_not_see_tasks_in_the_menu
    within '.app-tab-navigation' do
      expect(page).to have_text 'Feature flags'
      expect(page).to have_text 'Recruitment cycles'
      expect(page).to have_text 'Service banners'
      expect(page).to have_text 'Support users'
      expect(page).to have_no_text 'Tasks'
    end
  end

  def and_i_visit_the_tasks_page
    visit support_interface_tasks_path
  end

  def then_i_see_404_error
    expect(page).to have_text 'Page not found'
  end

  def then_i_see_tasks_content
    expect(page).to have_text 'Run end-of-cycle related jobs'
    expect(page).to have_text 'Delete test applications'
    expect(page).to have_text "Generate test applications for the #{current_year}"
    expect(page).to have_text "Generate test applications for the #{next_year}"
    expect(page).to have_text 'Create a fake provider for vendors'
  end

  def then_i_see_sandbox_tasks_content
    expect(page).to have_text 'Run end-of-cycle related jobs'
    expect(page).to have_no_text 'Delete test applications'
    expect(page).to have_no_text "Generate test applications for the #{current_year}"
    expect(page).to have_no_text "Generate test applications for the #{next_year}"
    expect(page).to have_no_text 'Create a fake provider for vendors'
  end

  alias_method :and_i_click_on, :click_on
end
