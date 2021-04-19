require 'rails_helper'

RSpec.describe 'A provider authenticates via DfE Sign-in from two separate devices' do
  include DfESignInHelpers

  let(:provider_user) { create(:provider_user, email_address: 'provider@example.com', dfe_sign_in_uid: 'DFE_SIGN_IN_UID', first_name: 'Michael') }

  scenario 'signing in successfully from two different devices' do
    given_i_am_registered_as_a_provider_user
    and_i_have_a_dfe_sign_in_account

    when_i_visit_the_provider_interface_sign_in_path
    and_i_sign_in_via_dfe_sign_in
    then_i_am_redirected_to_the_provider_interface_applications_path

    when_i_click_sign_out
    and_sign_in_from_a_different_device
    then_i_receive_a_confirmation_email_with_correct_details

    when_i_click_sign_out
    and_i_sign_in_again_from_the_same_device
    then_i_should_not_receive_a_new_notification_email
  end

  def given_i_am_registered_as_a_provider_user
    provider_user
  end

  def and_i_have_a_dfe_sign_in_account
    provider_exists_in_dfe_sign_in(
      email_address: 'provider@example.com',
      dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
      first_name: 'Mike',
    )
  end

  def when_i_visit_the_provider_interface_sign_in_path
    visit provider_interface_sign_in_path
  end

  def and_i_sign_in_via_dfe_sign_in
    click_button 'Sign in using DfE Sign-in'
  end

  def then_i_am_redirected_to_the_provider_interface_applications_path
    expect(page).to have_current_path(provider_interface_applications_path)
  end

  def when_i_click_sign_out
    click_link 'Sign out'
  end

  def and_sign_in_from_a_different_device
    browser = Capybara.current_session.driver.browser
    browser.clear_cookies

    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('192.168.0.1')
    allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return('Firefox')
    # rubocop:enable RSpec/AnyInstance

    visit provider_interface_applications_path
    click_button 'Sign in using DfE Sign-in'
  end

  def then_i_receive_a_confirmation_email_with_correct_details
    open_email('provider@example.com')
    expect(current_email).to have_content('We detected you signed into Manage teacher training applications on a new device.')
    expect(current_email).to have_content('192.168.0.1')
    expect(current_email).to have_content('Firefox')
  end

  def and_i_sign_in_again_from_the_same_device
    clear_emails
    visit provider_interface_sign_in_path
    click_button 'Sign in using DfE Sign-in'
  end

  def then_i_should_not_receive_a_new_notification_email
    open_email('provider@example.com')
    expect(current_email).to have_content('')
  end
end
