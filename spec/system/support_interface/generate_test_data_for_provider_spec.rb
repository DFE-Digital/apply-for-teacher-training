require 'rails_helper'

RSpec.describe 'Generate test data for provider via support', :sandbox, sidekiq: false do
  include DfESignInHelpers

  scenario 'Support user generates test applications' do
    given_i_am_a_support_user
    and_there_is_a_provider_with_no_open_courses_on_apply

    when_i_visit_the_support_provider_applications_page
    then_i_will_not_see_the_generate_test_data_button
    and_i_see_guidance_text

    when_the_provider_has_courses_open
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
    expect(page).to have_no_button 'Generate test applications'
  end

  def and_i_see_guidance_text
    expect(page).to have_content `Before we can generate test data, #{@provider.name_and_code} needs at least one course published in the current cycle.`
  end

  def when_the_provider_has_courses_open
    course = create(:course, :open, provider: @provider)
    create(:course_option, course:)
  end

  def then_i_see_the_generate_test_data_button
    expect(page).to have_button 'Generate test applications'
  end

  def when_i_click_on_generate_test_applications
    click_link_or_button 'Generate test applications'
  end

  def then_i_see_that_the_job_has_been_scheduled
    expect(page).to have_content 'Scheduled a job to generate test applications'
  end
end
