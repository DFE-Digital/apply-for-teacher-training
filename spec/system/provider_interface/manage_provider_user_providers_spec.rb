require 'rails_helper'

RSpec.feature 'Managing providers a user has access to' do
  include DfESignInHelpers

  scenario 'Provider adds and removes providers from a user' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_can_manage_users_for_two_providers
    and_there_is_a_user_with_access_to_one_of_the_providers
    and_i_sign_in_to_the_provider_interface

    when_i_click_on_the_users_link
    and_i_click_on_a_user
    then_i_see_only_the_first_provider
    and_i_click_change_providers

    when_i_remove_all_permissions
    then_i_see_a_validation_error

    when_i_give_permission_to_access_the_other_provider
    then_i_can_see_the_new_permission_for_the_provider_user
    and_unrelated_permissions_have_not_been_changed
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_can_manage_users_for_two_providers
    provider_user_exists_in_apply_database
    @managing_user = ProviderUser.find_by(dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    @provider = create(:provider, :with_signed_agreement)
    @another_provider = create(:provider, :with_signed_agreement)

    create(:provider_permissions, provider: @provider, provider_user: @managing_user, manage_users: true)
    create(:provider_permissions, provider: @another_provider, provider_user: @managing_user, manage_users: true)
  end

  def and_there_is_a_user_with_access_to_one_of_the_providers
    @provider_that_current_user_does_not_have_access_to = create(:provider)
    @managed_user = create(:provider_user, providers: [@provider, @provider_that_current_user_does_not_have_access_to])
  end

  def when_i_click_on_the_users_link
    click_on(t('page_titles.provider.organisation_settings'))
    click_on(t('page_titles.provider.users'))
  end

  def and_i_click_on_a_user
    click_on(@managed_user.full_name)
  end

  def then_i_see_only_the_first_provider
    expect(page).to have_content @provider.name
    expect(page).not_to have_content @another_provider.name
  end

  def and_i_click_change_providers
    click_on('Change organisations')
  end

  def when_i_remove_all_permissions
    uncheck @provider.name
    click_on 'Save'
  end

  def then_i_see_a_validation_error
    expect(page).to have_content 'Select which organisations this user will have access to'
  end

  def when_i_give_permission_to_access_the_other_provider
    check @another_provider.name
    click_on 'Save'
  end

  def then_i_can_see_the_new_permission_for_the_provider_user
    expect(page).to have_content 'User’s access successfully updated'
    expect(page).not_to have_content @provider.name
    expect(page).to have_content @another_provider.name
  end

  def and_unrelated_permissions_have_not_been_changed
    expect(@managed_user.providers).to include(@provider_that_current_user_does_not_have_access_to)
  end
end
