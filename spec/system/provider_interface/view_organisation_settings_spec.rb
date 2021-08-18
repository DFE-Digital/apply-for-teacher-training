require 'rails_helper'

RSpec.feature 'Organisation settings' do
  include DfESignInHelpers

  before { FeatureFlag.activate(:account_and_org_settings_changes) }

  scenario 'Provider user views organisation settings' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_belong_to_a_single_provider
    and_its_relationship_permissions_have_already_been_set_up
    and_i_sign_in_to_the_provider_interface

    when_i_click_on_the_organisation_settings_link
    then_i_see_the_organisation_settings_page
    and_i_see_a_link_to_manage_users_for_my_provider
    and_i_see_a_link_to_manage_organisation_permissions_for_my_provider

    given_i_belong_to_a_second_provider
    and_i_click_on_the_organisation_settings_link
    then_i_see_both_of_my_providers
    and_i_cannot_see_a_link_to_manage_organisation_permissions_for_the_second_provider
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_belong_to_a_single_provider
    provider_user_exists_in_apply_database
    @provider_user = ProviderUser.find_by(dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    @first_provider = Provider.find_by(code: 'ABC')
    @second_provider = Provider.find_by(code: 'DEF')
    @provider_user.update(providers: [@first_provider])
    ProviderPermissions.find_by(provider: @first_provider, provider_user: @provider_user).update(manage_organisations: true)
  end

  def and_its_relationship_permissions_have_already_been_set_up
    course = create(:course, :open_on_apply, :with_accredited_provider, provider: @first_provider)
    create(
      :provider_relationship_permissions,
      training_provider: @first_provider,
      ratifying_provider: course.accredited_provider,
    )
  end

  def when_i_click_on_the_organisation_settings_link
    within('#navigation') do
      click_on('Organisation settings')
    end
  end

  alias_method(
    :and_i_click_on_the_organisation_settings_link,
    :when_i_click_on_the_organisation_settings_link,
  )

  def then_i_see_the_organisation_settings_page
    expect(page).to have_current_path(provider_interface_organisation_settings_path)
  end

  def and_i_see_a_link_to_manage_users_for_my_provider
    expect(page).to have_link("Users #{@first_provider.name}", href: provider_interface_organisation_settings_organisation_users_path(@first_provider))
  end

  def and_i_see_a_link_to_manage_organisation_permissions_for_my_provider
    expected_org_permissions_path = provider_interface_organisation_settings_organisation_organisation_permissions_path(@first_provider)
    expect(page).to have_link("Organisation permissions #{@first_provider.name}", href: expected_org_permissions_path)
  end

  def given_i_belong_to_a_second_provider
    @provider_user.update(providers: [@first_provider, @second_provider])
  end

  def then_i_see_both_of_my_providers
    expect(page).to have_selector('h2', text: @first_provider.name)
    expect(page).to have_selector('h2', text: @second_provider.name)
  end

  def and_i_cannot_see_a_link_to_manage_organisation_permissions_for_the_second_provider
    expect(page).not_to have_content("Organisation permissions #{@second_provider.name}")
  end
end
