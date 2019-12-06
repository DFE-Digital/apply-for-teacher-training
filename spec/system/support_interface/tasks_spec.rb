require 'rails_helper'

RSpec.feature 'Tasks' do
  include DfESignInHelpers

  scenario 'Support user performs a task' do
    given_i_am_a_support_user

    when_i_visit_the_support_tasks_page
    and_i_click_on_generate_test_applications
    then_i_see_that_the_job_has_been_scheduled
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_i_visit_the_support_tasks_page
    visit support_interface_tasks_path
  end

  def and_i_click_on_generate_test_applications
    click_button 'Generate test application'
  end

  def then_i_see_that_the_job_has_been_scheduled
    expect(page).to have_content 'Scheduled job to generate test applications'
  end
end
