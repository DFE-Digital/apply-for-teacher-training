require 'rails_helper'

RSpec.feature 'Providers can view managed users' do
  include DfESignInHelpers
  include DsiAPIHelper

  # Behaviour tested here has moved to spec/system/provider_interface/view_organisation_users_spec.rb
  before { FeatureFlag.deactivate(:account_and_org_settings_changes) }

  scenario 'Provider use can see their individual users permissions' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_can_manage_applications_for_two_providers
    and_i_can_manage_users_for_a_provider
    and_i_sign_in_to_the_provider_interface
    and_i_have_some_providers_that_can_managed_users

    when_i_click_on_the_users_link
    and_i_click_on_a_users_name
    and_i_cannot_see_providers_i_do_not_belong_to
    the_users_details_should_be_visible
  end

  def and_i_have_some_providers_that_can_managed_users
    @current_provider_user = ProviderUser.find_by(dfe_sign_in_uid: 'DFE_SIGN_IN_UID')

    @provider = Provider.find_by(code: 'ABC')
    @another_provider = Provider.find_by(code: 'DEF')
    @non_visible_provider = create(:provider)

    @manageable_user = create(:provider_user, providers: [@provider, @non_visible_provider])

    @current_provider_user.provider_permissions.update_all(manage_users: true)

    @manageable_user.provider_permissions.find_by(provider: @provider).update(manage_users: true)
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_can_manage_applications_for_two_providers
    provider_user_exists_in_apply_database
    @current_provider_user = ProviderUser.find_by(dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    @provider = Provider.find_by(code: 'ABC')
    @another_provider = Provider.find_by(code: 'DEF')
  end

  def and_i_can_manage_users_for_a_provider
    @current_provider_user.provider_permissions.find_by(provider: @provider).update(manage_users: true)
  end

  def when_i_click_on_the_users_link
    click_on(t('page_titles.provider.organisation_settings'))
    click_on(t('page_titles.provider.users'))
  end

  def and_i_click_on_a_users_name
    click_link(@manageable_user.full_name, match: :first)
  end

  def and_i_cannot_see_providers_i_do_not_belong_to
    expect(page).not_to have_content(@non_visible_provider.name)
  end

  def the_users_details_should_be_visible
    expect(page).to have_content(@manageable_user.full_name)
    expect(page).to have_content('Permissions')
    expect(page).to have_content('Manage users')
    expect(page).to have_content('Example Provider')
    expect(page).not_to have_content('Another Provider')
  end
end
