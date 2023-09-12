require 'rails_helper'

RSpec.feature 'Candidate signs in and starts blank application in Sandbox', :sandbox do
  include SignInHelper

  scenario 'User is directed to prefill option page and chooses to start a blank application' do
    and_a_course_is_available
    and_i_am_a_candidate_with_a_blank_application

    when_i_fill_in_the_sign_in_form
    and_i_click_on_the_link_in_my_email_and_sign_in
    then_i_am_taken_to_the_prefill_application_page

    when_i_select_blank_application_and_submit_the_form
    then_i_am_taken_to_the_blank_application_page
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

  def when_i_select_blank_application_and_submit_the_form
    choose 'Start with a blank application form'
    click_on t('continue')
  end

  def then_i_am_taken_to_the_blank_application_page
    expect(page).to have_current_path(candidate_interface_application_form_path)
    expect(page).not_to have_content 'This application has been prefilled with example data'
    expect(page).to have_content 'Personal information Incomplete'
  end
end
