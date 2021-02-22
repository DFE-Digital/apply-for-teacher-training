require 'rails_helper'

RSpec.feature 'Add course to submitted application' do
  include DfESignInHelpers

  scenario 'Support user adds course to submitted application' do
    given_i_am_a_support_user
    and_there_is_a_submitted_application_in_the_system_logged_by_a_candidate
    and_i_visit_the_support_page

    when_i_click_on_an_application
    when_i_click_on_add_a_course

    then_i_should_see_the_course_search_page
    when_i_click_search
    then_i_should_see_a_course_code_blank_validation_error

    when_i_fill_in_the_course_code_for_a_course_that_does_not_exist
    and_i_click_search
    then_i_should_see_the_course_results_page_with_no_results

    when_i_click_search_again
    then_i_should_see_the_course_search_page_with_the_course_code_i_entered

    when_i_enter_a_course_code_for_a_course_that_does_exist
    and_i_click_search
    then_i_should_see_the_course_results_page_with_results

    when_i_click_add_course_to_application
    then_i_should_see_an_add_course_validation_error

    when_i_select_a_course
    and_i_click_add_course_to_application
    then_i_should_see_the_application_with_the_course_added

    when_there_are_two_more_courses_added
    and_i_visit_the_application_page
    then_i_should_not_be_able_to_add_further_courses

    when_one_course_is_withdrawn
    and_i_visit_the_application_page
    then_i_should_be_able_to_add_further_courses
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_a_submitted_application_in_the_system_logged_by_a_candidate
    candidate = create :candidate, email_address: 'alice@example.com'

    @application_form = Audited.audit_class.as_user(candidate) do
      create(
        :completed_application_form,
        first_name: 'Alice',
        last_name: 'Wunder',
        candidate: candidate,
      )
    end
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def when_i_click_on_an_application
    click_on 'Alice Wunder'
  end

  def when_i_click_on_add_a_course
    click_on 'Add a course'
  end

  def then_i_should_see_the_course_search_page
    expect(page).to have_current_path support_interface_application_form_search_course_new_path(application_form_id: @application_form.id)
  end

  def when_i_click_search
    click_on 'Search'
  end

  def then_i_should_see_a_course_code_blank_validation_error
    expect(page).to have_content 'Please enter a course code'
  end

  def when_i_fill_in_the_course_code_for_a_course_that_does_not_exist
    @non_existent_course_code = 'ABCD'
    fill_in('Course code', with: @non_existent_course_code)
  end

  def and_i_click_search
    when_i_click_search
  end

  def then_i_should_see_the_course_results_page_with_no_results
    expect(page).to have_current_path support_interface_application_form_new_course_path(
      application_form_id: @application_form.id,
      course_code: @non_existent_course_code,
    )
    expect(page).to have_content 'No results'
  end

  def when_i_click_search_again
    click_link 'Search again'
  end

  def then_i_should_see_the_course_search_page_with_the_course_code_i_entered
    expect(page).to have_current_path support_interface_application_form_search_course_new_path(
      application_form_id: @application_form.id,
      course_code: @non_existent_course_code,
    )
  end

  def when_i_enter_a_course_code_for_a_course_that_does_exist
    @course_option = create(:course_option)
    @course_code = @course_option.course.code
    fill_in('Course code', with: @course_code)
  end

  def then_i_should_see_the_course_results_page_with_results
    expect(page).to have_current_path support_interface_application_form_new_course_path(
      application_form_id: @application_form.id,
      course_code: @course_code,
    )

    expect(page).to have_content 'Which course should be added to the application?'
  end

  def when_i_click_add_course_to_application
    click_on 'Add course to application'
  end

  def then_i_should_see_an_add_course_validation_error
    expect(page).to have_content('Please select a course')
  end

  def when_i_select_a_course
    choose "#{@course_option.course.name} (#{@course_code}) - #{@course_option.site.name}"
  end

  def and_i_click_add_course_to_application
    when_i_click_add_course_to_application
  end

  def then_i_should_see_the_application_with_the_course_added
    expect(page).to have_current_path support_interface_application_form_path(application_form_id: @application_form.id)
    expect(page).to have_content("#{RecruitmentCycle.current_year}: #{@course_option.course.name} (#{@course_option.course.code})")
  end

  def when_there_are_two_more_courses_added
    create_list(:submitted_application_choice, 2, application_form: @application_form)
  end

  def and_i_visit_the_application_page
    visit support_interface_application_form_path(application_form_id: @application_form.id)
  end

  def then_i_should_not_be_able_to_add_further_courses
    expect(page).to have_content 'This application already has the maximum number of active course choices'
    expect(page).not_to have_link 'Add a course'
  end

  def when_one_course_is_withdrawn
    application_choice = @application_form.application_choices.last
    ApplicationStateChange.new(application_choice).withdraw!
    application_choice.update(withdrawn_at: Time.zone.now)
  end

  def then_i_should_be_able_to_add_further_courses
    expect(page).to have_link 'Add a course'
  end
end
