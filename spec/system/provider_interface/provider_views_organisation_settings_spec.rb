require 'rails_helper'

RSpec.feature 'Provider views organisation settings' do
  include DfESignInHelpers

  scenario 'Provider views organisation settings' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_can_view_applications_for_some_providers
    and_their_organisational_permissions_have_already_been_set_up
    and_the_accredited_provider_setting_permissions_flag_is_active
    and_i_sign_in_to_the_provider_interface

    when_i_cannot_manage_users_or_organisations
    then_i_do_not_see_the_organisation_settings_link

    when_i_can_manage_users_or_organisations
    then_i_can_see_the_organisation_settings_link

    when_i_click_on_the_organisation_settings_link
    then_i_see_the_organisation_settings_page
    and_i_see_a_link_to_manage_users
    and_i_see_a_link_to_manage_organisations

    when_i_click_to_manage_users
    then_the_breadcrumbs_are_correct_for_this_flow
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_can_view_applications_for_some_providers
    provider_user_exists_in_apply_database
    @user = ProviderUser.find_by(dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    @example_provider = Provider.find_by(code: 'ABC')
    @another_provider = Provider.find_by(code: 'DEF')
  end

  def and_their_organisational_permissions_have_already_been_set_up
    create(
      :provider_relationship_permissions,
      training_provider: @example_provider,
      ratifying_provider: @another_provider,
    )
  end

  def and_the_accredited_provider_setting_permissions_flag_is_active
    FeatureFlag.activate(:accredited_provider_setting_permissions)
  end

  def when_i_cannot_manage_users_or_organisations
    admin_permissions = ProviderPermissions.where(
      'manage_users OR manage_organisations',
    )

    expect(admin_permissions).to be_empty
  end

  def then_i_do_not_see_the_organisation_settings_link
    expect(page).not_to have_link('Organisation settings')
  end

  def when_i_can_manage_users_or_organisations
    ProviderPermissions.find_by(
      provider_user: @user,
      provider: @another_provider,
    ).update!(manage_users: true, manage_organisations: true)

    visit provider_interface_applications_path
  end

  def then_i_can_see_the_organisation_settings_link
    expect(page).to have_link('Organisation settings', href: provider_interface_organisation_settings_path)
  end

  def when_i_click_on_the_organisation_settings_link
    within('#navigation') do
      click_on('Organisation settings')
    end
  end

  def then_i_see_the_organisation_settings_page
    expect(page).to have_current_path(provider_interface_organisation_settings_path)
  end

  def and_i_see_a_link_to_manage_users
    expect(page).to have_link('Users', href: provider_interface_provider_users_path)
  end

  def and_i_see_a_link_to_manage_organisations
    expect(page).to have_link('Organisation permissions', href: provider_interface_organisation_settings_organisation_permissions_path)
  end

  def when_i_click_to_manage_users
    click_on('Users')
  end

  def then_the_breadcrumbs_are_correct_for_this_flow
    within('ol.govuk-breadcrumbs__list') do
      expect(page).to have_content('Organisation settings')
    end
  end

  def and_the_accredited_provider_setting_permissions_flag_is_inactive
    FeatureFlag.deactivate(:accredited_provider_setting_permissions)
  end
end
