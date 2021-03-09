require 'rails_helper'

RSpec.feature 'A new candidate is encouraged to select a course' do
  include SignInHelper

  scenario 'Candidate is redirected to the before you start page on their first sign in' do
    given_the_pilot_is_open

    when_i_visit_apply
    and_i_confirm_i_am_not_already_signed_up
    and_i_submit_my_email_address
    and_click_on_the_magic_link
    then_i_should_see_the_before_you_start_page
    and_i_should_see_an_account_created_flash_message
    when_i_click_choose_a_course
    then_i_should_see_the_course_choices_choose_page

    when_i_sign_out
    when_i_visit_apply
    and_i_confirm_i_am_not_already_signed_up
    and_i_submit_my_email_address
    and_click_on_the_magic_link
    then_i_should_see_the_before_you_start_page
    and_i_should_not_see_an_account_created_flash_message

    when_i_click_on_go_to_my_application
    then_i_should_see_the_application_page
    and_i_should_not_see_an_account_created_flash_message

    when_i_amend_my_application
    when_i_sign_out

    when_i_visit_apply
    and_i_confirm_i_am_not_already_signed_up
    and_i_submit_my_email_address
    and_click_on_the_magic_link
    then_i_should_see_the_application_page
    and_i_should_not_see_an_account_created_flash_message
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def when_i_visit_apply
    visit candidate_interface_create_account_or_sign_in_path
  end

  def and_i_confirm_i_am_not_already_signed_up
    choose 'No, I need to create an account'
    click_button t('continue')
  end

  def and_i_submit_my_email_address
    @email = "#{SecureRandom.hex}@example.com" if @email.blank?
    fill_in t('authentication.sign_up.email_address.label'), with: @email
    check t('authentication.sign_up.accept_terms_checkbox')
    click_on t('continue')
  end

  def and_click_on_the_magic_link
    open_email(@email)
    click_magic_link_in_email
    confirm_sign_in
  end

  def then_i_should_see_the_before_you_start_page
    expect(page).to have_current_path(candidate_interface_before_you_start_path)
  end

  def and_i_should_see_an_account_created_flash_message
    expect(page).to have_content(t('apply_from_find.account_created_message'))
  end

  def when_i_click_choose_a_course
    click_link 'Choose a course'
  end

  def then_i_should_see_the_course_choices_choose_page
    expect(page).to have_current_path(candidate_interface_course_choices_choose_path)
  end

  def when_i_visit_the_before_you_start_page
    visit candidate_interface_before_you_start_path
  end

  def when_i_click_on_go_to_my_application
    click_link 'Go to your application form'
  end

  def then_i_should_see_the_application_page
    expect(page).to have_current_path(candidate_interface_application_form_path)
  end

  def and_i_should_not_see_an_account_created_flash_message
    expect(page).not_to have_content(t('apply_from_find.account_created_message'))
  end

  def when_i_amend_my_application
    click_on 'Maths GCSE or equivalent'
    choose('GCSE')
    click_button t('save_and_continue')
    fill_in 'Please specify your grade', with: 'A'
    click_button t('save_and_continue')
    fill_in 'Enter year', with: '1990'
    click_button t('save_and_continue')
  end

  def when_i_sign_out
    click_on 'Sign out'
  end
end
