require 'rails_helper'

RSpec.feature 'Managing provider users' do
  include DfESignInHelpers
  include DsiAPIHelper

  scenario 'creating a new provider user' do
    given_dfe_signin_is_configured
    and_i_am_a_support_user
    and_providers_exist

    when_i_visit_the_support_console
    and_i_click_the_users_link
    and_i_click_the_manange_provider_users_link
    and_i_click_the_add_user_link
    and_i_enter_an_existing_email
    and_i_click_add_user
    then_i_see_an_error

    and_i_enter_the_users_email_and_name
    and_i_select_a_provider
    and_i_click_add_user

    then_i_should_see_the_list_of_provider_users
    and_i_should_see_the_user_i_created
    and_the_user_should_be_sent_a_welcome_email

    when_the_user_has_not_signed_in_yet
    and_i_click_on_that_user
    then_their_email_should_not_be_editable

    when_i_add_them_to_another_organisation
    then_i_see_that_they_have_been_added_to_that_organisation

    when_they_have_signed_in_at_least_once
    and_i_reload_the_page
    then_their_email_should_be_editable
  end

  def given_dfe_signin_is_configured
    set_dsi_api_response(success: true)
  end

  def and_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_providers_exist
    create(:provider, name: 'Example provider', code: 'ABC')
    create(:provider, name: 'Another provider', code: 'DEF')
  end

  def when_i_visit_the_support_console
    visit support_interface_path
  end

  def and_i_click_the_users_link
    click_link 'Users'
  end

  def and_i_click_the_manange_provider_users_link
    click_link 'Provider users'
  end

  def and_i_select_a_provider
    check 'Example provider (ABC)'
  end

  def and_i_click_the_add_user_link
    click_link 'Add provider user'
  end

  def and_i_enter_an_existing_email
    create(:provider_user, email_address: 'existing@example.org')
    fill_in 'support_interface_provider_user_form[email_address]', with: 'Existing@example.org'
  end

  def then_i_see_an_error
    expect(page).to have_content 'This email address is already in use'
  end

  def and_i_enter_the_users_email_and_name
    fill_in 'support_interface_provider_user_form[email_address]', with: 'harrison@example.com'
    fill_in 'support_interface_provider_user_form[first_name]', with: 'Harrison'
    fill_in 'support_interface_provider_user_form[last_name]', with: 'Bergeron'
  end

  def and_i_click_add_user
    click_button 'Add provider user'
  end

  def then_i_should_see_the_list_of_provider_users
    expect(page).to have_title('Provider users')
  end

  def and_i_should_see_the_user_i_created
    expect(page).to have_content('harrison@example.com')
  end

  def and_the_user_should_be_sent_a_welcome_email
    open_email('harrison@example.com')
    expect(current_email.subject).to have_content t('provider_account_created.email.subject')
  end

  def and_i_click_on_that_user
    click_link 'harrison@example.com'
  end

  def when_i_add_them_to_another_organisation
    check 'Another provider (DEF)'
    click_button 'Update user'
  end

  def then_i_see_that_they_have_been_added_to_that_organisation
    expect(page).to have_checked_field('Example provider (ABC)')
    expect(page).to have_checked_field('Another provider (DEF)')
  end

  def when_the_user_has_not_signed_in_yet; end

  def then_their_email_should_not_be_editable
    expect(page).to have_field 'Email address', disabled: true
    expect(page).to have_content 'The email address is not editable'
  end

  def when_they_have_signed_in_at_least_once
    user = ProviderUser.find_by(email_address: 'harrison@example.com')
    user.update!(dfe_sign_in_uid: 'ABC123')
  end

  def and_i_reload_the_page
    page.refresh
  end

  def then_their_email_should_be_editable
    expect(page).to have_field 'Email address', disabled: false
  end
end
