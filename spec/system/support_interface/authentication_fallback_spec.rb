require 'rails_helper'

RSpec.describe 'A support authenticates via the fallback mechanism' do
  include DfESignInHelpers

  scenario 'signing in successfully' do
    FeatureFlag.activate('dfe_sign_in_fallback')

    given_i_am_registered_as_a_support_user
    when_i_visit_the_support_interface_applications_path
    then_i_am_redirected_to_the_support_sign_in_path

    when_i_provide_my_email_address
    then_i_receive_an_email_with_a_signin_link
    when_i_click_on_the_link_in_my_email
    then_i_am_signed_in

    when_i_sign_out
    then_i_am_not_signed_in

    given_the_feature_flag_is_switched_off
    when_i_click_on_the_link_in_my_email
    then_i_am_not_signed_in
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

  def when_i_provide_my_email_address
    fill_in 'Email address', with: 'sUpPoRt@example.com '
    click_on 'Continue'
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
      expect(page).to have_content 'Sign out'
    end
  end

  def when_i_sign_out
    click_on 'Sign out'
  end

  def given_the_feature_flag_is_switched_off
    FeatureFlag.deactivate('dfe_sign_in_fallback')
  end

  def then_i_am_not_signed_in
    within 'header' do
      expect(page).not_to have_content @email
    end
  end
end
