require 'rails_helper'

RSpec.feature 'Provider edits organisation permissions' do
  include DfESignInHelpers

  scenario 'Provider edits organisation permissions' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_can_view_applications_for_some_providers
    and_their_organisational_permissions_have_already_been_set_up
    and_i_can_manage_organisations_for_my_provider
    and_the_accredited_provider_setting_permissions_flag_is_active
    and_i_sign_in_to_the_provider_interface

    when_i_click_on_the_organisation_settings_link
    and_i_click_on_organisation_permissions
    and_i_click_on_an_organisation_i_can_manage
    and_i_click_to_change_one_of_its_relationships
    and_i_give_my_organisation_permission_to_make_decisions
    then_i_am_redirected_to_the_organisation_relationships_page
    and_i_see_a_flash_message
    and_my_organisation_is_listed_as_able_to_make_decisions
    and_my_organisation_is_able_to_make_decisions
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_can_view_applications_for_some_providers
    provider_user_exists_in_apply_database
    @user = ProviderUser.find_by(dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    @training_provider = Provider.find_by(code: 'ABC')
    @ratifying_provider = Provider.find_by(code: 'DEF')
  end

  def and_their_organisational_permissions_have_already_been_set_up
    @relationship = create(
      :provider_relationship_permissions,
      training_provider: @training_provider,
      ratifying_provider: @ratifying_provider,
    )

    expect(@relationship.ratifying_provider_can_make_decisions).to be_falsey
  end

  def and_the_accredited_provider_setting_permissions_flag_is_active
    FeatureFlag.activate(:accredited_provider_setting_permissions)
  end

  def and_i_can_manage_organisations_for_my_provider
    ProviderPermissions.find_by(
      provider_user: @user,
      provider: @ratifying_provider,
    ).update!(manage_organisations: true)
  end

  def when_i_click_on_the_organisation_settings_link
    click_on 'Organisation settings'
  end

  def and_i_click_on_organisation_permissions
    click_on 'Organisation permissions'
  end

  def and_i_click_on_an_organisation_i_can_manage
    within('.app-application-card div h2') do
      click_on @ratifying_provider.name
    end
  end

  def and_i_click_to_change_one_of_its_relationships
    click_on 'Change'
  end

  def and_i_give_my_organisation_permission_to_make_decisions
    check 'provider-relationship-permissions-ratifying-provider-can-make-decisions-true-field'
    click_on 'Save organisation permissions'
  end

  def then_i_am_redirected_to_the_organisation_relationships_page
    expect(page).to have_current_path(provider_interface_organisation_settings_organisation_permission_path(@ratifying_provider))
  end

  def and_i_see_a_flash_message
    expect(page).to have_content('Organisation permissions successfully updated')
  end

  def and_my_organisation_is_listed_as_able_to_make_decisions
    expect(page).to have_content("Make offers and reject applications\n#{@training_provider.name}#{@ratifying_provider.name}")
  end

  def and_my_organisation_is_able_to_make_decisions
    expect(@relationship.reload.ratifying_provider_can_make_decisions).to be_truthy
  end
end
