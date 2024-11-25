require 'rails_helper'

RSpec.describe 'Candidate signs in and prefills application in Sandbox', :sandbox do
  include SignInHelper
  include CandidateHelper

  scenario 'User is directed to prefill option page and chooses to prefill the application' do
    and_a_course_is_available
    and_i_am_a_candidate_with_a_blank_application

    when_i_fill_in_the_sign_in_form
    and_i_click_on_the_link_in_my_email_and_sign_in
    then_i_am_taken_to_the_prefill_application_page

    when_i_select_prefill_and_submit_the_form
    then_i_am_taken_to_your_applications_page
    and_there_is_a_flash_saying_the_application_was_prefilled
    and_my_application_has_been_filled_in

    when_i_submit_one_of_my_draft_applications
    then_my_application_is_submitted_successfully
  end

  def and_a_course_is_available
    @course_option = create(:course_option, course: create(:course, :open, recruitment_cycle_year: RecruitmentCycle.current_year))
  end

  def and_i_am_a_candidate_with_a_blank_application
    @candidate = create(:candidate)
    @application_form = create(:application_form, candidate: @candidate)
    @application_choice = create(:application_choice, :unsubmitted, application_form: @application_form, course_option: @course_option)
  end

  def when_i_fill_in_the_sign_in_form
    visit candidate_interface_sign_in_path
    fill_in t('authentication.sign_up.email_address.label'), with: @candidate.email_address
    and_i_click_continue
  end

  def and_i_click_on_the_link_in_my_email_and_sign_in
    open_email(@candidate.email_address)
    click_magic_link_in_email
    confirm_sign_in
  end

  def then_i_am_taken_to_the_prefill_application_page
    expect(page).to have_current_path(candidate_interface_prefill_path)
  end

  def when_i_select_prefill_and_submit_the_form
    choose 'Start with the form filled in automatically'
    and_i_click_continue
  end

  def then_i_am_taken_to_your_applications_page
    expect(page).to have_current_path(candidate_interface_application_choices_path)
  end

  def and_there_is_a_flash_saying_the_application_was_prefilled
    expect(page).to have_content 'This application has been prefilled with example data'
  end

  def and_my_application_has_been_filled_in
    expect(page).to have_no_content 'Incomplete'
  end

  def then_my_application_is_submitted_successfully
    expect(page).to have_content 'Application submitted'
  end
end
