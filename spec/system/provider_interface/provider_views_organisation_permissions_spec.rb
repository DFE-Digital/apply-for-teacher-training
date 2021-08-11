require 'rails_helper'

RSpec.feature 'Viewing organisation permissions' do
  include DfESignInHelpers

  scenario 'Provider user views their organisation permissions page with various permissions' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_can_manage_multiple_organisations_that_do_not_have_permissions_set_up
    and_i_sign_in_to_the_provider_interface

    when_i_go_to_organisation_settings
    then_i_cannot_see_organisational_permissions

    when_i_set_up_permissions_for_a_provider
    and_i_go_to_organisation_settings
    and_i_click_organisation_permissions
    then_i_can_see_organisations_with_setup_permissions

    when_i_go_to_the_training_provider_permissions
    then_i_can_only_see_permissions_that_have_been_set_up_for_the_training_provider

    when_i_click_organisation_permissions
    then_i_go_to_the_ratifying_provider_permissions
    then_i_can_see_permissions_that_have_been_set_up_for_the_ratifying_provider
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_user_is_associated_with_a_training_provider
  end

  def provider_user_is_associated_with_a_training_provider
    @training_provider = create(:provider, :with_signed_agreement, code: 'ABC')
    @ratifying_provider = create(:provider, :with_signed_agreement, code: 'DEF')
    @another_ratifying_provider = create(:provider, :with_signed_agreement, code: 'GHI')
    create(:provider_user,
           :with_manage_users,
           :with_notifications_enabled,
           providers: [@training_provider, @ratifying_provider],
           dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
           email_address: 'email@provider.ac.uk')
  end

  def and_i_can_manage_multiple_organisations_that_do_not_have_permissions_set_up
    @provider_user = ProviderUser.last

    @permission_one = create(
      :provider_relationship_permissions,
      training_provider: @training_provider,
      ratifying_provider: @ratifying_provider,
      setup_at: nil,
    )

    @permission_two = create(
      :provider_relationship_permissions,
      training_provider: @training_provider,
      ratifying_provider: @another_ratifying_provider,
      setup_at: nil,
    )

    @provider_user.provider_permissions.update_all(manage_organisations: true)
  end

  def when_i_go_to_organisation_settings
    click_on t('page_titles.provider.organisation_settings')
  end

  def then_i_cannot_see_organisational_permissions
    expect(page).to have_content(t('page_titles.provider.users'))
    expect(page).not_to have_content(t('page_titles.provider.organisation_permissions'))
  end

  def when_i_set_up_permissions_for_a_provider
    @permission_one.update(setup_at: Time.zone.now)
  end

  alias_method :and_i_go_to_organisation_settings, :when_i_go_to_organisation_settings

  def and_i_click_organisation_permissions
    click_on t('page_titles.provider.organisation_permissions')
  end

  def then_i_can_see_organisations_with_setup_permissions
    expect(page).to have_content(@training_provider.name.to_s)
    expect(page).to have_content(@ratifying_provider.name.to_s)
  end

  alias_method :when_i_click_organisation_permissions, :and_i_click_organisation_permissions

  def when_i_go_to_the_training_provider_permissions
    click_on @training_provider.name.to_s
  end

  def then_i_go_to_the_ratifying_provider_permissions
    click_on @ratifying_provider.name.to_s
  end

  def then_i_can_only_see_permissions_that_have_been_set_up_for_the_training_provider
    expect(page).to have_content("#{@training_provider.name} and #{@ratifying_provider.name}")
    expect(page).not_to have_content("#{@training_provider.name} and #{@another_ratifying_provider.name}")
  end

  def then_i_can_see_permissions_that_have_been_set_up_for_the_ratifying_provider
    expect(page).to have_content("#{@ratifying_provider.name} and #{@training_provider.name}")
  end
end
