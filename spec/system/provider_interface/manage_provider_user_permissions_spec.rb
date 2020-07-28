require 'rails_helper'

RSpec.feature 'Managing provider user permissions' do
  include DfESignInHelpers

  scenario 'Provider manages permissions for users' do
    FeatureFlag.activate(:providers_can_manage_users_and_permissions)

    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_can_manage_applications_for_two_providers
    and_i_can_manage_users_for_a_provider
    and_i_sign_in_to_the_provider_interface

    when_i_click_on_the_users_link
    when_i_click_on_a_user
    then_i_see_a_breadcrumb
    and_i_click_to_change_permissions

    then_i_see_user_permissions_for_this_provider
    and_i_add_permission_to_manage_users_for_a_provider_user
    then_i_can_see_the_manage_users_permission_for_the_provider_user
    and_i_click_to_change_permissions

    when_i_remove_manage_users_permissions_from_a_provider_user
    then_i_cant_see_the_manage_users_permission_for_the_provider_user

    and_i_click_to_change_permissions

    when_i_add_permission_to_view_safeguarding_for_a_provider_user
    then_i_can_see_the_view_safeguarding_permission_for_the_provider_user

    and_i_click_to_change_permissions

    and_i_add_permission_to_make_decisions_for_a_provider_user
    then_i_can_see_the_make_decisions_permission_for_the_provider_user
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_can_manage_applications_for_two_providers
    provider_user_exists_in_apply_database
    @managing_user = ProviderUser.find_by(dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    @provider = Provider.find_by(code: 'ABC')
    @another_provider = Provider.find_by(code: 'DEF')
  end

  def and_i_can_manage_users_for_a_provider
    @managed_user = create(:provider_user, providers: [@provider], first_name: 'Sylvia', last_name: 'Mead')
    @managing_user.provider_permissions.find_by(provider: @provider).update(manage_users: true)
  end

  def when_i_click_on_the_users_link
    click_on('Users')
  end

  def when_i_click_on_a_user
    click_on(@managed_user.full_name)
  end

  def and_i_click_to_change_permissions
    click_on('Change')
  end

  def then_i_see_user_permissions_for_this_provider
    expect(page).to have_unchecked_field 'Manage users'
  end

  def then_i_see_a_breadcrumb
    within '.govuk-breadcrumbs' do
      expect(page).to have_link('Users')
      expect(page).to have_content('Sylvia Mead')
    end
  end

  def and_i_add_permission_to_manage_users_for_a_provider_user
    expect(page).not_to have_checked_field 'Manage users'
    check 'Manage users'
    click_on 'Save'
  end

  def then_i_can_see_the_manage_users_permission_for_the_provider_user
    expect(page).to have_content 'Permissions updated'

    within("#provider-#{@provider.id}-enabled-permissions") do
      expect(page).to have_content 'Manage users'
    end
  end

  def when_i_remove_manage_users_permissions_from_a_provider_user
    expect(page).to have_checked_field 'Manage users'
    uncheck 'Manage users'
    click_on 'Save'
  end

  def then_i_cant_see_the_manage_users_permission_for_the_provider_user
    expect(page).to have_content 'Permissions updated'
    expect(page).not_to have_content 'Manage users'
  end

  def when_i_add_permission_to_view_safeguarding_for_a_provider_user
    expect(page).not_to have_checked_field 'View safeguarding information'
    check 'View safeguarding information'
    click_on 'Save'
  end

  def then_i_can_see_the_view_safeguarding_permission_for_the_provider_user
    within("#provider-#{@provider.id}-enabled-permissions") do
      expect(page).to have_content 'View safeguarding information'
    end
  end

  def and_i_add_permission_to_make_decisions_for_a_provider_user
    expect(page).not_to have_checked_field 'Make decisions'
    check 'Make decisions'
    click_on 'Save'
  end

  def then_i_can_see_the_make_decisions_permission_for_the_provider_user
    within("#provider-#{@provider.id}-enabled-permissions") do
      expect(page).to have_content 'Make decisions'
    end
  end
end
