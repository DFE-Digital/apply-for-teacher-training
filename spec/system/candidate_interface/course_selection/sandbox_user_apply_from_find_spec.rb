require 'rails_helper'

RSpec.describe 'A sandbox user arriving from Find with a course and provider code', sandbox: true do
  include SignInHelper

  scenario 'can prefill their application with their chosen course' do
    given_the_pilot_is_open
    and_i_do_not_have_an_account
    and_a_course_and_course_option_exists
    and_i_am_on_the_apply_from_find_page_with_a_course_and_provider_code

    when_i_choose_to_apply_through_apply
    and_i_confirm_i_am_not_already_signed_up
    then_i_see_the_sign_up_page

    when_i_sign_up
    then_i_am_signed_in
    and_i_see_the_prefill_application_form

    when_i_select_prefill_application
    then_i_see_the_course_choice_has_been_added_to_my_application
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def and_i_do_not_have_an_account
    @email = "#{SecureRandom.hex}@example.com"
  end

  def and_a_course_and_course_option_exists
    @provider = create(:provider, code: 'DEF')
    @course_on_apply = create(:course, exposed_in_find: true, open_on_apply: true, code: 'DEF1', name: 'Potions', provider: @provider)
    @course_options_on_apply = create_list(:course_option, 3, course: @course_on_apply)
  end

  def and_i_am_on_the_apply_from_find_page_with_a_course_and_provider_code
    visit candidate_interface_apply_from_find_path providerCode: @course_on_apply.provider.code, courseCode: @course_on_apply.code
  end

  def when_i_choose_to_apply_through_apply
    choose 'Yes, I want to apply using the new service'

    click_button t('continue')
  end

  def and_i_confirm_i_am_not_already_signed_up
    choose 'No, I need to create an account'
    click_button t('continue')
  end

  def then_i_see_the_sign_up_page
    expect(page).to have_content 'Create an Apply for teacher training account'
  end

  def when_i_sign_up
    check t('authentication.sign_up.accept_terms_checkbox')
    fill_in t('authentication.sign_up.email_address.label'), with: @email
    click_on t('continue')

    open_email(@email)
    expect(current_email.subject).to have_content t('authentication.sign_up.email.subject')

    click_magic_link_in_email
    confirm_sign_in
  end

  def then_i_am_signed_in
    within 'header' do
      expect(page).to have_content @email
    end
  end

  def and_i_see_the_prefill_application_form
    expect(page).to have_content('What do you want to do?')
  end

  def when_i_select_prefill_application
    choose 'Start with the form filled in automatically'
    click_button t('continue')
  end

  def then_i_see_the_course_choice_has_been_added_to_my_application
    click_link 'Choose your courses'
    expect(page).to have_content(@course_on_apply.name_and_code)
  end
end
