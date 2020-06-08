require 'rails_helper'

RSpec.feature 'Setting up provider relationship permissions' do
  include DfESignInHelpers

  scenario 'Provider user sets up permissions for their organisation' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_the_provider_permissions_feature_is_enabled
    and_i_can_manage_organisations
    and_my_organisation_has_not_had_permissions_setup

    when_i_sign_in_to_the_provider_interface
    then_i_should_see_the_permissions_setup_page
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_user_exists_in_apply_database
  end

  def and_the_provider_permissions_feature_is_enabled
    FeatureFlag.activate('enforce_provider_to_provider_permissions')
  end

  def and_i_can_manage_organisations
    @provider_user = ProviderUser.last
    @provider_user.provider_permissions.update_all(manage_organisations: true)
    @training_provider = Provider.find_by(code: 'ABC')
    @ratifying_provider = Provider.find_by(code: 'DEF')
  end

  def and_my_organisation_has_not_had_permissions_setup
    create(
      :accredited_body_permissions,
      ratifying_provider: @ratifying_provider,
      training_provider: @training_provider,
    )

    create(
      :training_provider_permissions,
      ratifying_provider: @ratifying_provider,
      training_provider: @training_provider,
    )
  end

  alias_method :when_i_sign_in_to_the_provider_interface, :and_i_sign_in_to_the_provider_interface

  def then_i_should_see_the_permissions_setup_page
    expect(page).to have_content('Set up permissions for your organisation')
  end
end
