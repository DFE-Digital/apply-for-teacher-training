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
    when_i_visit_the_invite_user_wizard
    then_i_see_a_404_page

    and_i_can_manage_users_for_two_provider
    and_i_sign_in_again_to_the_provider_interface

    # when_i_click_on_the_users_link
    # and_i_click_invite_user
    when_i_visit_the_invite_user_wizard
    then_i_see_the_basic_details_form

    when_i_press_continue
    then_i_see_validation_errors_for_names_and_email_address

    when_i_fill_in_email_address_and_name
    and_i_press_continue
    then_i_see_the_select_organisations_form

    when_i_select_one_provider
    and_i_press_continue
    then_i_see_the_select_permissions_form_for_selected_provider

    when_i_select_make_decisions_permission
    and_i_press_continue
    then_i_see_the_confirm_page

    # TODO: Assert the state of the confirm page

    when_i_commit_changes
    then_i_see_the_new_user_on_the_index_page
  end

  def when_i_try_to_visit_the_users_page
    visit provider_interface_provider_users_path
  end

  def then_i_see_a_404_page
    expect(page).to have_content('Page not found')
  end

  def when_i_visit_the_invite_user_wizard
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

  def and_i_can_manage_users_for_two_provider
    @provider_user.provider_permissions.find_by(provider: @provider).update(manage_users: true)
    @provider_user.provider_permissions.find_by(provider: @another_provider).update(manage_users: true)
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
    fill_in 'Email address', with: 'ed@example.com'
    fill_in 'First name', with: 'Ed'
    fill_in 'Last name', with: 'Ucator'
  end

  def and_i_press_continue
    click_on 'Continue'
  end
  alias_method :when_i_press_continue, :and_i_press_continue

  def then_i_see_validation_errors_for_names_and_email_address
    expect(page).to have_content('Enter the user\'s first name')
    expect(page).to have_content('Enter the user\'s last name')
    expect(page).to have_content('Enter the user\'s email address')
  end

  def then_i_see_the_select_organisations_form
    expect(page).to have_content('Select organisations this user will have access to')
  end

  def when_i_select_one_provider
    check 'Another Provider'
  end

  def then_i_see_the_select_permissions_form_for_selected_provider
    expect(page).to have_content('Set permissions for Another Provider')
  end

  def when_i_select_make_decisions_permission
    check 'Make decisions'
  end

  def then_i_see_the_confirm_page
    expect(page).to have_content('Check permissions before you invite user')
  end

  def when_i_commit_changes
    click_button 'Invite user'
  end

  def then_i_see_the_new_user_on_the_index_page
    expect(page).to have_content('User successfully invited')
    expect(page).to have_content('Ed Ucator')
  end
end
