require 'rails_helper'

RSpec.feature 'Candidate signs in and prefills application in Sandbox', sandbox: true do
  include SignInHelper

  scenario 'User is directed to prefill option page and chooses to prefill the application' do
    given_the_pilot_is_open
    and_a_course_is_available
    and_i_am_a_candidate_with_a_blank_application

    when_i_fill_in_the_sign_in_form
    and_i_click_on_the_link_in_my_email_and_sign_in
    then_i_am_taken_to_the_prefill_application_page

    when_i_select_prefill_and_submit_the_form
    then_i_am_taken_to_the_application_page
    and_there_is_a_flash_saying_the_application_was_prefilled
    and_my_application_has_been_filled_in

    when_i_click_submit_and_continue_and_send
    and_i_skip_feedback
    then_my_application_is_submitted_successfully
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def and_a_course_is_available
    create(:course_option, course: create(:course, :open_on_apply, recruitment_cycle_year: RecruitmentCycle.current_year))
  end

  def and_i_am_a_candidate_with_a_blank_application
    @candidate = create(:candidate)
    @application_form = create(:application_form, candidate: @candidate)
  end

  def when_i_fill_in_the_sign_in_form
    visit candidate_interface_sign_in_path
    fill_in t('authentication.sign_up.email_address.label'), with: @candidate.email_address
    click_on t('continue')
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
    click_on t('continue')
  end

  def then_i_am_taken_to_the_application_page
    expect(page).to have_current_path(candidate_interface_application_form_path)
  end

  def and_there_is_a_flash_saying_the_application_was_prefilled
    expect(page).to have_content 'This application has been prefilled with example data'
  end

  def and_my_application_has_been_filled_in
    expect(page).not_to have_content 'Incomplete'
    expect(page).not_to have_content 'In progress'
  end

  def when_i_click_submit_and_continue_and_send
    click_on 'Check and submit your application'
    click_on t('continue')
    expect(page).not_to have_content 'There is a problem'
    choose t('equality_and_diversity.choice.no.label')
    click_on t('continue')
    choose 'No'
    click_button t('application_form.submit_application.submit_button')
  end

  def and_i_skip_feedback
    click_button 'Continue'
  end

  def then_my_application_is_submitted_successfully
    expect(page).to have_content 'Application successfully submitted'
  end
end
