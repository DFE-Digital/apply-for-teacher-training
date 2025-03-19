require 'rails_helper'

RSpec.describe 'Add course to submitted application' do
  include DfESignInHelpers

  before do
    given_i_am_a_support_user
    and_there_is_a_submitted_application_in_the_system_with_an_accepted_offer
    and_i_visit_the_support_page
    when_i_click_on_an_application
  end

  scenario 'Support user adds course to submitted application' do
    when_i_click_on_change_offered_course
    then_i_see_the_change_offered_course_search_page

    when_i_click_search
    then_i_see_a_course_code_blank_validation_error

    when_i_fill_in_the_course_code_for_a_course_that_is_not_associated_with_the_ratifying_provider
    and_i_click_search
    then_i_see_the_course_results_page_with_results

    when_i_click_back
    and_i_enter_a_course_code_for_a_course_that_has_the_same_ratifying_provider
    and_i_click_search
    then_i_see_the_course_results_page_with_results

    when_i_click_to_change_the_offered_course
    then_i_see_an_add_course_validation_error

    when_i_select_a_course
    and_i_click_to_change_the_offered_course
    then_i_see_the_confirm_offered_course_page
    and_i_see_the_guidance_on_changing_an_offered_course

    when_i_provide_a_valid_zendesk_ticket
    and_i_confirm_changing_the_offer
    and_i_click_continue
    then_i_am_redirected_to_the_application_form_page
    and_i_see_new_course_has_been_offered
  end

  scenario 'Support user changes offered course for a submitted application to a course with no vacancies' do
    when_i_click_on_change_offered_course
    then_i_see_the_change_offered_course_search_page
    and_i_enter_a_course_code_for_a_course_that_has_no_vacancies
    and_i_click_search
    then_i_see_the_course_results_page_with_results

    when_i_select_a_course_with_no_vacancies
    and_i_click_to_change_the_offered_course
    then_i_see_the_confirm_offered_course_page
    and_i_see_the_guidance_on_changing_an_offered_course

    when_i_provide_a_valid_zendesk_ticket
    and_i_confirm_changing_the_offer
    and_i_click_continue
    then_i_see_a_warning_message
    and_a_confirm_course_change_checkbox

    when_i_confirm_changing_the_course
    and_i_click_continue
    then_i_am_redirected_to_the_application_form_page
    and_i_see_new_course_with_no_vacancies_has_been_offered
  end

  scenario 'Support user changes offered course where the new course is also available at other providers' do
    when_i_click_on_change_offered_course
    and_i_enter_a_course_code_which_is_available_at_the_same_provider_and_at_other_providers
    and_i_click_search
    then_i_see_the_course_results_page_with_results_for_the_same_provider
    and_i_see_the_course_results_page_with_results_for_other_providers
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_a_submitted_application_in_the_system_with_an_accepted_offer
    @application_form = create(:completed_application_form, first_name: 'Alice', last_name: 'Wunder')
    @application_choice = create(:application_choice, :accepted, application_form: @application_form)
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def when_i_click_on_an_application
    click_link_or_button 'Alice Wunder'
  end

  def when_i_click_on_change_offered_course
    click_link_or_button 'Change offered course'
  end

  def then_i_see_the_change_offered_course_search_page
    expect(page).to have_current_path support_interface_application_form_application_choice_change_offered_course_search_path(
      application_form_id: @application_form.id,
      application_choice_id: @application_choice.id,
    )
  end

  def when_i_click_search
    click_link_or_button 'Search'
  end

  def then_i_see_a_course_code_blank_validation_error
    expect(page).to have_content 'Please enter a course code'
  end

  def when_i_fill_in_the_course_code_for_a_course_that_is_not_associated_with_the_ratifying_provider
    @other_providers_course_option = create(:course_option, course: create(:course, :open))
    @course_code = @other_providers_course_option.course.code
    fill_in('Course code', with: @course_code)
  end

  def and_i_click_search
    when_i_click_search
  end

  def then_i_see_the_course_results_page_with_no_results
    expect(page).to have_current_path support_interface_application_form_application_choice_choose_offered_course_option_path(
      application_form_id: @application_form.id,
      application_choice_id: @application_choice.id,
      course_code: @unassociated_course_code,
    )

    expect(page).to have_content "No courses for #{@application_choice.provider.name_and_code} found."
  end

  def when_i_click_search_again
    click_link_or_button 'Search again'
  end

  def when_i_click_back
    click_link_or_button 'Back'
  end

  def and_i_enter_a_course_code_for_a_course_that_has_the_same_ratifying_provider
    @course_option = create(:course_option, course: create(:course, :open, provider: @application_choice.provider))
    @course_code = @course_option.course.code
    fill_in('Course code', with: @course_code)
  end

  def and_i_enter_a_course_code_for_a_course_that_has_no_vacancies
    @course_option = create(:course_option, :no_vacancies, course: create(:course, :open, funding_type: 'fee', provider: @application_choice.provider))
    @course_code = @course_option.course.code
    fill_in('Course code', with: @course_code)
  end

  def then_i_see_the_course_results_page_with_results
    expect(page).to have_current_path support_interface_application_form_application_choice_choose_offered_course_option_path(
      application_form_id: @application_form.id,
      application_choice_id: @application_choice.id,
      course_code: @course_code,
    )

    expect(page).to have_content "Choose a course to replace #{@application_choice.course.name_and_code}"
  end

  def then_i_see_an_add_course_validation_error
    expect(page).to have_content('Please select a course')
  end

  def when_i_select_a_course
    choose "#{@course_option.course.name} (#{@course_code})"
  end
  alias_method :when_i_select_a_course_with_no_vacancies, :when_i_select_a_course

  def when_i_click_to_change_the_offered_course
    click_link_or_button 'Continue'
  end

  def and_i_click_to_change_the_offered_course
    when_i_click_to_change_the_offered_course
  end

  def then_i_see_the_confirm_offered_course_page
    expect(page).to have_current_path support_interface_application_form_application_choice_confirm_offered_course_option_path(
      application_form_id: @application_form.id,
      application_choice_id: @application_choice.id,
      course_option_id: @course_option.id,
    )
  end

  def and_i_see_the_guidance_on_changing_an_offered_course
    expect(page).to have_content 'An offer can only be changed if:'
  end

  def when_i_provide_an_invalid_zendesk_ticket_link
    fill_in('Zendesk ticket URL', with: 'This wont work')
  end

  def then_i_am_told_that_i_need_to_provide_a_valid_zendesk_ticket_link
    expect(page).to have_content 'Enter a valid Zendesk ticket URL'
  end

  def when_i_provide_a_valid_zendesk_ticket
    fill_in('Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/example')
  end

  def and_i_confirm_changing_the_offer
    check 'I have read the guidance'
  end

  def and_i_click_continue
    click_link_or_button 'Continue'
  end

  def then_i_am_redirected_to_the_application_form_page
    expect(page).to have_current_path support_interface_application_form_path(application_form_id: @application_form.id)
  end

  def and_i_see_new_course_has_been_offered
    expect(page).to have_current_path support_interface_application_form_path(application_form_id: @application_form.id)
    expect(page).to have_content("#{current_year}: #{@course_option.course.name} (#{@course_option.course.code})")
  end
  alias_method :and_i_see_new_course_with_no_vacancies_has_been_offered, :and_i_see_new_course_has_been_offered

  def then_i_see_a_warning_message
    expect(page).to have_content(I18n.t('support_interface.errors.messages.course_full_error'))
  end

  def and_a_confirm_course_change_checkbox
    expect(page).to have_content 'I confirm that I would like to move the candidate to a course with no vacancies'
  end

  def when_i_confirm_changing_the_course
    find('input[name="support_interface_application_forms_update_offered_course_option_form[confirm_course_change]"]').check
  end

  def and_i_enter_a_course_code_which_is_available_at_the_same_provider_and_at_other_providers
    course_at_same_provider = create(:course, :open, funding_type: 'fee', provider: @application_choice.provider)
    @course_code = course_at_same_provider.code
    course_at_different_provider = create(:course, :open, funding_type: 'fee', provider: create(:provider), code: @course_code)

    @course_option_same_provider = create(:course_option, course: course_at_same_provider)
    @course_option_different_provider = create(:course_option, course: course_at_different_provider)

    fill_in('Course code', with: @course_code)
  end

  def then_i_see_the_course_results_page_with_results_for_the_same_provider
    expect(page).to have_content("Choose a course to replace #{@application_choice.course.name_and_code}")

    expect(page).to have_content("Courses from the same provider (#{@application_choice.provider.name_and_code})")
    within '.same-provider' do
      expect(page).to have_content(@course_option_same_provider.course.name_and_code)
    end
  end

  def and_i_see_the_course_results_page_with_results_for_other_providers
    expect(page).to have_content('Courses from other providers')
    within '.other-providers' do
      expect(page).to have_content("#{@course_option_different_provider.course.provider.name_and_code} – #{@course_option_different_provider.course.name_and_code}")
    end
  end
end
