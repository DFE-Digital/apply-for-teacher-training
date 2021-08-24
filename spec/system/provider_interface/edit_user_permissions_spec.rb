require 'rails_helper'

RSpec.feature 'User permissions' do
  include DfESignInHelpers

  before { FeatureFlag.activate(:account_and_org_settings_changes) }

  scenario 'Provider user edits another user’s permissions' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_can_manage_users_for_one_provider
    and_i_sign_in_to_the_provider_interface

    when_i_go_to_organisation_settings
    and_i_view_users_for_my_provider
    and_i_click_on_a_user
    and_i_click_on_the_change_link
    then_i_see_a_permissions_form_page
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_can_manage_users_for_one_provider
    @manage_users_provider = create(:provider, :with_signed_agreement, code: 'ABC')
    @provider_user = create(
      :provider_user,
      :with_manage_users,
      providers: [@manage_users_provider],
      dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
    )

    @manageable_user = create(:provider_user, providers: [@manage_users_provider])
  end

  def when_i_go_to_organisation_settings
    click_on 'Organisation settings', match: :first
  end

  def and_i_view_users_for_my_provider
    click_on "Users #{@manage_users_provider.name}"
  end

  def and_i_click_on_a_user
    click_on @manageable_user.full_name
  end

  def and_i_click_on_the_change_link
    click_on 'Change Manage users'
  end

  def then_i_see_a_permissions_form_page
    expect(page).to have_content("#{@manageable_user.full_name} - #{@manage_users_provider.name}")
    expect(page).to have_content('User permissions')
  end
end
