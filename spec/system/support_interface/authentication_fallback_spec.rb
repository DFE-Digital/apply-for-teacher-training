require 'rails_helper'

RSpec.describe 'A support authenticates via the fallback mechanism' do
  include DfESignInHelpers

  scenario 'signing in successfully' do
    FeatureFlag.activate('dfe_sign_in_fallback')

    given_i_am_registered_as_a_support_user
    when_i_visit_the_support_interface_applications_path
    then_i_am_redirected_to_the_support_sign_in_path

    when_i_do_not_provide_my_email_address
    then_i_see_a_validation_error

    when_i_provide_my_email_address
    then_i_receive_an_email_with_a_signin_link
    when_i_click_on_the_link_in_my_email
    then_i_see_a_confirm_sign_in_page

    when_i_click_on_sign_in
    then_i_am_signed_in

    when_i_sign_out
    then_i_am_not_signed_in

    when_i_click_an_incorrect_sign_in_link
    then_i_see_a_404

    given_the_feature_flag_is_switched_off
    when_i_click_on_the_link_in_my_email
    then_i_do_not_see_a_confirm_sign_in_page
    and_i_am_asked_to_sign_in_the_normal_way
  end

  def given_i_am_registered_as_a_support_user
    @email = 'support@example.com'
    @support_user = create(:support_user, email_address: @email, dfe_sign_in_uid: 'DFE_SIGN_IN_UID', first_name: 'Michael')
  end

  def when_i_visit_the_support_interface_applications_path
    visit support_interface_applications_path(some_key: 'some_value')
  end

  def then_i_am_redirected_to_the_support_sign_in_path
    expect(page).to have_current_path(support_interface_sign_in_path)
  end

  def when_i_do_not_provide_my_email_address
    fill_in 'Email address', with: ''
    click_button t('continue')
  end

  def then_i_see_a_validation_error
    expect(page).to have_content 'Enter an email address'
  end

  def when_i_provide_my_email_address
    fill_in 'Email address', with: 'sUpPoRt@example.com '
    click_button t('continue')
  end

  def then_i_receive_an_email_with_a_signin_link
    open_email(@email)
    expect(current_email.subject).to have_content t('authentication.sign_in.email.subject')
  end

  def when_i_click_on_the_link_in_my_email
    current_email.find_css('a').first.click
  end

  def then_i_see_a_confirm_sign_in_page
    expect(page).to have_content 'Confirm that you want to sign in'
  end

  def when_i_click_on_sign_in
    click_button 'Sign in'
  end

  def then_i_am_signed_in
    within 'header' do
      expect(page).to have_content 'Sign out'
    end
  end

  def when_i_sign_out
    click_link 'Sign out'
  end

  def given_the_feature_flag_is_switched_off
    FeatureFlag.deactivate('dfe_sign_in_fallback')
  end

  def then_i_am_not_signed_in
    within 'header' do
      expect(page).to have_no_content @email
    end
  end

  def when_i_click_an_incorrect_sign_in_link
    visit support_interface_authenticate_with_token_path(token: 'NOT_A_REAL_TOKEN')
  end

  def then_i_see_a_404
    expect(page).to have_content 'Page not found'
  end

  def then_i_do_not_see_a_confirm_sign_in_page
    expect(page).to have_no_content 'Confirm sign in'
  end

  def and_i_am_asked_to_sign_in_the_normal_way
    expect(page).to have_current_path(support_interface_sign_in_path)
  end
end
