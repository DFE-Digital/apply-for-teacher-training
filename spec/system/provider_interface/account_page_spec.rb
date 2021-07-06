require 'rails_helper'

RSpec.feature 'Viewing the provider user account page' do
  include DfESignInHelpers

  scenario 'Provider user visits their account page with various permissions' do
    given_i_am_a_provider_user_with_dfe_sign_in
    given_i_cannot_manage_users_or_organisations
    and_the_accredited_provider_setting_permissions_flag_is_inactive

    and_i_sign_in_to_the_provider_interface

    when_i_go_to_my_account
    then_i_can_only_see_the_manage_notifications_link

    given_i_can_manage_organisations_but_not_users

    when_i_go_to_my_account
    then_i_can_see_the_organisational_permissions_link_and_not_the_users_one

    given_i_can_manage_users_but_not_organisations

    when_i_go_to_my_account
    then_i_can_see_the_users_link_and_not_the_organisational_permissions_one
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_user_exists_in_apply_database
  end

  def given_i_cannot_manage_users_or_organisations
    @provider_user = ProviderUser.last
    @provider_user.provider_permissions.update_all(
      manage_organisations: false,
      manage_users: false,
    )
  end

  def then_i_can_only_see_the_manage_notifications_link
    expect(page).to have_content(t('page_titles.provider.notifications'))
    expect(page).not_to have_content(t('page_titles.provider.users'))
    expect(page).not_to have_content(t('page_titles.provider.org_permissions'))
  end

  def given_i_can_manage_organisations_but_not_users
    training_provider = Provider.find_by(code: 'ABC')
    ratifying_provider = Provider.find_by(code: 'DEF')

    create(
      :provider_relationship_permissions,
      training_provider: training_provider,
      ratifying_provider: ratifying_provider,
    )

    @provider_user.provider_permissions.update_all(manage_organisations: true)
  end

  def when_i_go_to_my_account
    click_on t('page_titles.provider.account')
  end

  def then_i_can_see_the_organisational_permissions_link_and_not_the_users_one
    expect(page).to have_content(t('page_titles.provider.org_permissions'))
    expect(page).not_to have_content(t('page_titles.provider.users'))
  end

  def given_i_can_manage_users_but_not_organisations
    @provider_user.provider_permissions.update_all(
      manage_organisations: false,
      manage_users: true,
    )
  end

  def then_i_can_see_the_users_link_and_not_the_organisational_permissions_one
    expect(page).to have_content(t('page_titles.provider.users'))
    expect(page).not_to have_content(t('page_titles.provider.org_permissions'))
  end

  def and_the_accredited_provider_setting_permissions_flag_is_inactive
    FeatureFlag.deactivate(:accredited_provider_setting_permissions)
  end
end
