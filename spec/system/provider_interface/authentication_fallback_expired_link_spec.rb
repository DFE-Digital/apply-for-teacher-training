require 'rails_helper'

RSpec.describe 'A provider with an expired DSI fallback link' do
  include DfESignInHelpers

  scenario 'signs in by requesting a new token' do
    FeatureFlag.activate('dfe_sign_in_fallback')

    given_i_am_registered_as_a_provider_user
    when_i_visit_the_interviews_schedule_path
    then_i_am_redirected_to_the_provider_sign_in_path

    when_i_provide_my_email_address
    then_i_receive_an_email_with_a_signin_link
    when_i_visit_the_link_in_my_email
    then_i_see_a_confirm_sign_in_page
    when_i_click_on_sign_in
    then_i_am_signed_in

    when_i_sign_out
    then_i_am_not_signed_in

    when_i_visit_the_link_in_my_email
    then_i_see_the_expired_token_page

    when_i_request_a_new_token
    then_i_receive_an_email_with_a_signin_link

    when_i_visit_the_link_in_my_email
    then_i_see_a_confirm_sign_in_page

    when_i_click_on_sign_in
    then_i_am_signed_in
  end

  def given_i_am_registered_as_a_provider_user
    @email = 'provider@example.com'
    @provider_user = create(:provider_user, email_address: @email, dfe_sign_in_uid: 'DFE_SIGN_IN_UID', first_name: 'Michael')
  end

  def when_i_visit_the_provider_interface_applications_path
    visit provider_interface_applications_path(some_key: 'some_value')
  end

  def when_i_visit_the_interviews_schedule_path
    visit provider_interface_interview_schedule_path
  end

  def then_i_am_redirected_to_the_provider_sign_in_path
    expect(page).to have_current_path(provider_interface_sign_in_path)
  end

  def when_i_provide_my_email_address
    fill_in 'Email address', with: 'pRoViDeR@example.com '
    click_link_or_button 'Request link to sign in'
  end

  def then_i_do_not_receive_an_email_with_a_signin_link
    open_email(@email)
    expect(current_email).not_to be_present
  end

  def then_i_receive_an_email_with_a_signin_link
    open_email(@email)
    expect(current_email.subject).to have_content 'Sign in - manage teacher training applications'
  end

  def when_i_visit_the_link_in_my_email
    uri = URI(current_email.find_css('a').first.text)
    visit "#{uri.path}?#{uri.query}"
  end

  def then_i_see_the_expired_token_page
    expect(page).to have_content 'The link to sign in has expired'
  end

  def when_i_request_a_new_token
    click_link_or_button 'Request another link to sign in'
  end

  def then_i_see_a_confirm_sign_in_page
    expect(page).to have_content 'Confirm that you want to sign in'
  end

  def when_i_click_on_sign_in
    click_button('Sign in')
    # rubocop:enable Capybara/ClickLinkOrButtonStyle
  end

  def then_i_am_signed_in
    within 'header' do
      expect(page).to have_content 'Sign out'
    end
  end

  def when_i_sign_out
    click_link_or_button 'Sign out'
  end

  def then_i_am_not_signed_in
    within 'header' do
      expect(page).to have_no_content @email
    end
  end
end
