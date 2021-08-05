require 'rails_helper'

RSpec.feature 'Organisation settings' do
  include DfESignInHelpers

  before { FeatureFlag.activate(:account_and_org_settings_changes) }

  scenario 'Provider user views organisation settings' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_can_view_applications_for_some_providers
    and_i_sign_in_to_the_provider_interface
    then_i_can_see_the_organisation_settings_link
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_can_view_applications_for_some_providers
    provider_user_exists_in_apply_database
    @user = ProviderUser.find_by(dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
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
    expect(page).to have_link('Organisation permissions', href: provider_interface_organisation_settings_organisations_path)
  end
end
