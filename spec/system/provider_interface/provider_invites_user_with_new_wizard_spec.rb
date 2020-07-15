require 'rails_helper'

RSpec.feature 'Provider invites a new provider user using wizard interface' do
  include DfESignInHelpers
  include DsiAPIHelper

  scenario 'Provider sends invite to user' do
    FeatureFlag.activate(:providers_can_manage_users_and_permissions)

    # TODO: test what happens with the feature flag off
    # TODO: test what happens without necessary permissions

    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_can_manage_applications_for_two_providers
    and_i_sign_in_to_the_provider_interface

    when_i_try_to_visit_the_users_page
    then_i_see_a_404_page
    when_i_try_to_visit_the_invite_user_wizard
    then_i_see_a_404_page

    and_i_can_manage_users_for_a_provider
    and_i_sign_in_again_to_the_provider_interface

    when_i_click_on_the_users_link
    and_i_click_invite_user
    then_i_see_the_basic_details_form

    when_i_fill_in_email_address_and_name
    and_i_press_continue
    then_i_see_the_select_organisations_form

    when_i_select_one_provider
    and_i_press_continue
    then_i_see_the_select_permissions_form_for_selected_provider

    # TODO: TBC
  end

  def when_i_try_to_visit_the_users_page
    visit provider_interface_provider_users_path
  end

  def then_i_see_a_404_page
    expect(page).to have_content('Page not found')
  end

  def when_i_try_to_visit_the_invite_user_wizard
    visit provider_interface_edit_invitation_basic_details_path
  end

  def when_i_click_on_the_users_link
    click_on('Users')
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_can_manage_applications_for_two_providers
    provider_user_exists_in_apply_database
    @provider_user = ProviderUser.find_by(dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    @provider = Provider.find_by(code: 'ABC')
    @another_provider = Provider.find_by(code: 'DEF')
  end

  def and_i_can_manage_users_for_a_provider
    @provider_user.provider_permissions.find_by(provider: @provider).update(manage_users: true)
  end

  def and_i_sign_in_again_to_the_provider_interface
    click_link('Sign out')
    and_i_sign_in_to_the_provider_interface
  end

  def and_i_click_invite_user
    click_on 'Invite user'
  end

  def then_i_see_the_basic_details_form
    expect(page).to have_content('Basic details')
  end

  def when_i_fill_in_email_address_and_name
    fill_in 'Email address', with: 'alice@example.com'
    fill_in 'First name', with: 'Alice'
    fill_in 'Last name', with: 'Alistair'
  end

  def and_i_press_continue
    click_on 'Continue'
  end

  def then_i_see_the_select_organisations_form
  end

  def when_i_select_one_provider
  end

  def then_i_see_the_select_permissions_form_for_selected_provider
  end
end
