require 'rails_helper'

RSpec.feature 'Generate test data for provider via support', sidekiq: false, sandbox: true do
  include DfESignInHelpers

  scenario 'Support user generates test applications' do
    given_i_am_a_support_user
    and_there_is_a_provider_with_no_open_courses_on_apply

    when_i_visit_the_support_provider_applications_page
    then_i_will_not_see_the_generate_test_data_button

    when_the_provider_has_courses_open_on_apply
    and_i_visit_the_support_provider_applications_page
    then_i_see_the_generate_test_data_button

    when_i_click_on_generate_test_applications
    then_i_see_that_the_job_has_been_scheduled
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_a_provider_with_no_open_courses_on_apply
    @provider = create(:provider)
  end

  def when_i_visit_the_support_provider_applications_page
    visit support_interface_provider_applications_path(@provider)
  end
  alias_method :and_i_visit_the_support_provider_applications_page, :when_i_visit_the_support_provider_applications_page

  def then_i_will_not_see_the_generate_test_data_button
    expect(page).not_to have_button 'Generate test applications'
  end

  def when_the_provider_has_courses_open_on_apply
    course = create(:course, :open_on_apply, provider: @provider)
    create(:course_option, course: course)
  end

  def then_i_see_the_generate_test_data_button
    expect(page).to have_button 'Generate test applications'
  end

  def when_i_click_on_generate_test_applications
    click_button 'Generate test applications'
  end

  def then_i_see_that_the_job_has_been_scheduled
    expect(page).to have_content 'Scheduled a job to generate test applications'
  end
end
