require 'rails_helper'

RSpec.feature 'Provider invites a new provider user' do
  include DfESignInHelpers
  include DsiAPIHelper

  scenario 'Provider sends invite to user' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_can_manage_applications_for_two_providers
    and_i_can_manage_users_for_a_provider
    and_i_sign_in_to_the_provider_interface
    and_the_provider_add_provider_users_feature_is_enabled

    when_i_visit_the_provider_users_index
    and_i_click_invite_user
    and_i_fill_in_and_submit_invite_details

    then_a_new_provider_user_is_created
    and_the_user_should_be_sent_a_welcome_email
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

  def and_the_provider_add_provider_users_feature_is_enabled
    FeatureFlag.activate('provider_add_provider_users')
  end

  def when_i_visit_the_provider_users_index
    visit provider_interface_provider_users_path
  end

  def and_i_click_invite_user
    click_on 'Invite user'
  end

  def and_i_fill_in_and_submit_invite_details
    set_dsi_api_response(success: true)
    @email_address = "jane.smith+#{rand(1000)}@example.com"

    fill_in 'First name', with: 'Jane'
    fill_in 'Last name', with: 'Smith'
    fill_in 'Email address', with: @email_address

    expect(page).not_to have_content(@another_provider.name_and_code)

    check @provider.name_and_code

    click_on 'Invite provider user'
  end

  def then_a_new_provider_user_is_created
    @new_provider_user = ProviderUser.find_by(email_address: @email_address)
    expect(@new_provider_user).not_to be nil
    expect(@new_provider_user.providers).to include(@provider)
    expect(page).to have_content('Provider user invited')
  end

  def and_the_user_should_be_sent_a_welcome_email
    open_email(@email_address)
    expect(current_email.subject).to have_content t('provider_account_created.email.subject')
  end
end
