require 'rails_helper'

RSpec.feature 'Candidate reviewing an application with unavailable course options' do
  include CandidateHelper

  scenario 'sees warning messages for unavailable course options' do
    given_i_am_signed_in
    and_the_unavailable_course_option_warnings_feature_is_active
    and_i_chose_course_options_that_have_since_become_unavailable

    when_i_visit_the_review_application_page
    then_i_see_a_warning_for_the_course_that_is_not_running
    then_i_see_a_warning_for_the_course_with_no_vacancies
    then_i_see_a_warning_for_the_course_with_no_vacancies_at_my_chosen_site

    when_i_submit_the_application
    then_i_see_error_messages_for_the_things_i_was_warned_about

    when_i_swap_course_option_with_one_unavailable_on_apply

    when_i_visit_the_review_application_page
    then_i_see_a_warning_that_my_course_is_no_longer_on_apply

    when_i_submit_the_application
    then_i_see_error_messages_for_the_course_closed_on_apply_i_was_warned_about
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_the_unavailable_course_option_warnings_feature_is_active
    FeatureFlag.activate('unavailable_course_option_warnings')
  end

  def and_i_chose_course_options_that_have_since_become_unavailable
    @option_where_course_not_running = create(
      :course_option,
      course: create(:course, exposed_in_find: false, open_on_apply: true),
    )

    @option_where_course_has_no_vacancies = create(
      :course_option,
      :no_vacancies,
      course: create(:course, exposed_in_find: true, open_on_apply: true),
    )
    create(:course_option, :no_vacancies, course: @option_where_course_has_no_vacancies.course)

    @option_where_no_vacancies_at_chosen_site = create(
      :course_option,
      :no_vacancies,
      course: create(:course, exposed_in_find: true, open_on_apply: true),
    )
    create(:course_option, course: @option_where_no_vacancies_at_chosen_site.course)

    [
      @option_where_course_not_running,
      @option_where_course_has_no_vacancies,
      @option_where_no_vacancies_at_chosen_site,
    ].each do |option|
      create(
        :application_choice,
        application_form: @current_candidate.current_application,
        course_option: option,
      )
    end
  end

  def when_i_visit_the_review_application_page
    visit candidate_interface_application_form_path
    click_link 'Check and submit your application'
  end

  def then_i_see_a_warning_for_the_course_that_is_not_running
    expect(page).to have_content course_not_running_message
  end

  def then_i_see_a_warning_for_the_course_with_no_vacancies
    expect(page).to have_content course_has_no_vacancies_message
  end

  def then_i_see_a_warning_for_the_course_with_no_vacancies_at_my_chosen_site
    expect(page).to have_content chosen_site_has_no_vacancies_message
  end

  def when_i_submit_the_application
    click_link 'Continue'
  end

  def then_i_see_error_messages_for_the_things_i_was_warned_about
    within('.govuk-error-summary') do
      expect(page).to have_content course_not_running_message
    end
  end

  def when_i_swap_course_option_with_one_unavailable_on_apply
    @option_where_course_not_running.course.update!(
      exposed_in_find: true,
      open_on_apply: false,
    )
  end

  def then_i_see_a_warning_that_my_course_is_no_longer_on_apply
    expect(page).to have_content(course_closed_on_apply_message)
    expect(page).to have_content("You can still apply for '#{@option_where_course_not_running.course.name_and_code}' on UCAS.")
  end

  def then_i_see_error_messages_for_the_course_closed_on_apply_i_was_warned_about
    within('.govuk-error-summary') do
      expect(page).to have_content course_closed_on_apply_message
    end
  end

private

  def course_not_running_message
    "You cannot apply to '#{@option_where_course_not_running.course.provider_and_name_code}' because it is not running"
  end

  def course_has_no_vacancies_message
    "You cannot apply to '#{@option_where_course_has_no_vacancies.course.provider_and_name_code}' because it has no vacancies"
  end

  def chosen_site_has_no_vacancies_message
    "Your chosen site for '#{@option_where_no_vacancies_at_chosen_site.course.provider_and_name_code}' has no vacancies"
  end

  def course_closed_on_apply_message
    "'#{@option_where_course_not_running.course.name_and_code}' at #{@option_where_course_not_running.course.provider.name} is not available on Apply for teacher training anymore"
  end
end
