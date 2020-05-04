require 'rails_helper'

RSpec.describe 'A provider authenticates via the fallback mechanism' do
  include DfESignInHelpers

  scenario 'signing in successfully' do
    FeatureFlag.activate('dfe_sign_in_fallback')

    given_i_am_registered_as_a_provider_user_without_a_dsi_uid
    when_i_visit_the_provider_interface_applications_path
    then_i_am_redirected_to_the_provider_sign_in_path

    when_i_provide_my_email_address
    then_i_do_not_receive_an_email_with_a_signin_link

    when_i_get_a_dsi_uid
    when_i_visit_the_provider_interface_applications_path
    then_i_am_redirected_to_the_provider_sign_in_path

    when_i_provide_my_email_address
    then_i_receive_an_email_with_a_signin_link
    when_i_click_on_the_link_in_my_email
    then_i_am_signed_in
  end

  def given_i_am_registered_as_a_provider_user_without_a_dsi_uid
    @email = 'provider@example.com'
    @provider_user = create(:provider_user, email_address: @email, dfe_sign_in_uid: nil, first_name: 'Michael')
  end

  def when_i_get_a_dsi_uid
    @provider_user.update(dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
  end

  def when_i_visit_the_provider_interface_applications_path
    visit provider_interface_applications_path(some_key: 'some_value')
  end

  def then_i_am_redirected_to_the_provider_sign_in_path
    expect(page).to have_current_path(provider_interface_sign_in_path)
  end

  def when_i_provide_my_email_address
    fill_in 'Email address', with: 'pRoViDeR@example.com'
    click_on 'Continue'
  end

  def then_i_do_not_receive_an_email_with_a_signin_link
    open_email(@email)
    expect(current_email).not_to be_present
  end

  def then_i_receive_an_email_with_a_signin_link
    open_email(@email)
    expect(current_email.subject).to have_content t('authentication.sign_in.email.subject')
  end

  def when_i_click_on_the_link_in_my_email
    current_email.find_css('a').first.click
  end

  def then_i_am_signed_in
    within 'header' do
      expect(page).to have_content @email
    end
  end

  def and_we_have_been_notified
    expect_slack_message_with_text "Provider user #{@provider_user.first_name} has signed in via the fallback mechanism"
  end
end
