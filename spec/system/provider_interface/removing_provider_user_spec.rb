require 'rails_helper'

RSpec.describe 'Removing a provider user' do
  include DfESignInHelpers

  before { FeatureFlag.deactivate(:account_and_org_settings_changes) }

  scenario 'removing a user from all providers', with_audited: true do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_can_manage_applications_for_two_providers
    and_i_can_manage_users_for_a_provider
    and_a_provider_user_with_many_providers_exists
    and_i_sign_in_to_the_provider_interface

    when_i_click_on_the_users_link
    and_i_click_on_a_user_with_many_providers
    and_i_click_delete_user
    and_i_confirm_i_want_to_delete_this_user

    then_the_deleted_user_has_no_visible_provider_permissions
    and_the_audit_log_has_been_updated

    when_i_click_invite_user
    and_i_reinvite_the_deleted_user
    then_i_can_see_the_user_and_their_permissions
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
    @managing_user.provider_permissions
      .where(provider: [@provider, @another_provider])
      .update_all(manage_users: true)
  end

  def and_a_provider_user_with_many_providers_exists
    @non_visible_provider = create(:provider)
    @user_to_remove = create(:provider_user, providers: [@provider, @another_provider, @non_visible_provider])
  end

  def when_i_click_on_the_users_link
    click_on(t('page_titles.provider.organisation_settings'))
    click_on(t('page_titles.provider.users'))
  end

  def and_i_click_on_a_user_with_many_providers
    click_on @user_to_remove.full_name
  end

  def and_i_click_delete_user
    click_on 'Delete user'
  end

  def and_i_confirm_i_want_to_delete_this_user
    click_on 'Yes I’m sure - delete this account'
  end

  def then_the_deleted_user_has_no_visible_provider_permissions
    expect(page).to have_content 'User’s account successfully deleted'
    expect(page).not_to have_content(@user_to_remove.full_name)
    expect(@user_to_remove.reload.providers).to eq([@non_visible_provider])
  end

  def and_the_audit_log_has_been_updated
    expect(@user_to_remove.own_and_associated_audits.first(2).pluck(:action, :auditable_type)).to eql([%w[destroy ProviderPermissions], %w[destroy ProviderPermissions]])
  end

  def when_i_click_invite_user
    click_on 'Invite user'
  end

  def and_i_reinvite_the_deleted_user
    fill_in 'Email address', with: @user_to_remove.email_address
    fill_in 'First name', with: @user_to_remove.first_name
    fill_in 'Last name', with: @user_to_remove.last_name
    click_on t('continue')

    check @provider.name
    click_on t('continue')

    choose 'Extra permissions'
    check 'Make decisions'
    click_on t('continue')

    click_on 'Invite user'
  end

  def then_i_can_see_the_user_and_their_permissions
    expect(page).to have_content('User successfully invited')

    expect(page).to have_content(@user_to_remove.full_name)
  end
end
