require 'rails_helper'

RSpec.describe 'Organisation users' do
  include DfESignInHelpers

  before { FeatureFlag.activate(:account_and_org_settings_changes) }

  scenario 'Provider user removes another user from one of their organisations' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_can_manage_users_for_one_provider
    and_i_cannot_manage_users_for_another_provider
    and_a_provider_user_belonging_to_both_providers_exists
    and_i_sign_in_to_the_provider_interface

    when_i_click_on_the_users_link_for(@manage_users_provider)
    and_i_click_on_the_user_to_remove
    and_i_click_delete_user
    and_i_confirm_i_want_to_delete_this_user
    then_i_see_the_success_message
    and_the_user_no_longer_belongs_to_the_provider

    when_i_click_on_the_users_link_for(@read_only_provider)
    and_i_click_on_the_user_to_remove
    then_i_cannot_see_a_link_to_delete_the_user
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
      email_address: 'email@provider.ac.uk',
    )
  end

  def and_i_cannot_manage_users_for_another_provider
    @read_only_provider = create(:provider, :with_signed_agreement, code: 'DEF')
    create(:provider_permissions, provider_user: @provider_user, provider: @read_only_provider)
  end

  def and_a_provider_user_belonging_to_both_providers_exists
    @user_to_remove = create(:provider_user, providers: [@manage_users_provider, @read_only_provider])
  end

  def when_i_click_on_the_users_link_for(provider)
    click_on 'Organisation settings', match: :first
    click_on("Users #{provider.name}")
  end

  def and_i_click_on_the_user_to_remove
    click_on @user_to_remove.full_name
  end

  def and_i_click_delete_user
    click_on 'Delete user'
  end

  def and_i_confirm_i_want_to_delete_this_user
    and_i_click_delete_user
  end

  def then_i_see_the_success_message
    expect(page).to have_content('User deleted')
  end

  def and_the_user_no_longer_belongs_to_the_provider
    expect(page).not_to have_content(@user_to_remove.full_name)
    expect(@user_to_remove.reload.providers).to contain_exactly(@read_only_provider)
  end

  def then_i_cannot_see_a_link_to_delete_the_user
    expect(page).not_to have_link('Delete user')
  end
end
