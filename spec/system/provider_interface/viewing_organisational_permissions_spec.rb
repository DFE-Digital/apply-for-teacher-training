require 'rails_helper'

RSpec.feature 'Viewing organisational permissions' do
  include DfESignInHelpers

  scenario 'Provider user uses their account page with various permissions' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_the_accredited_provider_setting_permissions_flag_is_inactive

    and_i_sign_in_to_the_provider_interface

    given_i_can_manage_multiple_organisations_that_do_not_have_permissions_set_up

    when_i_go_to_my_account
    then_i_cannot_see_organisational_permissions

    when_i_set_up_permissions_for_a_provider
    and_i_go_to_my_account
    then_i_can_see_organisational_permissions

    when_i_go_to_organisational_permissions
    then_i_can_see_organisations_with_setup_permissions

    when_i_go_to_the_training_provider_permissions
    then_i_can_only_see_permissions_that_have_been_set_up

    when_i_go_to_organisational_permissions
    then_i_go_to_the_ratifying_provider_permissions
    then_i_can_only_see_permissions_that_have_been_set_up
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
           :with_notifications_enabled,
           providers: [@training_provider, @ratifying_provider],
           dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
           email_address: 'email@provider.ac.uk')
  end

  def then_i_cannot_see_organisational_permissions
    expect(page).to have_content(t('page_titles.provider.notifications'))
    expect(page).not_to have_content(t('page_titles.provider.org_permissions'))
  end

  def then_i_can_see_organisational_permissions
    expect(page).to have_content(t('page_titles.provider.org_permissions'))
  end

  def given_i_can_manage_multiple_organisations_that_do_not_have_permissions_set_up
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

  def then_i_can_see_organisations_with_setup_permissions
    expect(page).to have_content(@training_provider.name.to_s)
    expect(page).to have_content(@ratifying_provider.name.to_s)
  end

  def when_i_set_up_permissions_for_a_provider
    @permission_one.update(setup_at: Time.zone.now)
  end

  def when_i_go_to_my_account
    click_on t('page_titles.provider.account')
  end

  def when_i_go_to_organisational_permissions
    click_on 'Organisational permissions'
  end

  def when_i_go_to_the_training_provider_permissions
    click_on @training_provider.name.to_s
  end

  def then_i_go_to_the_ratifying_provider_permissions
    click_on @ratifying_provider.name.to_s
  end

  def then_i_can_only_see_permissions_that_have_been_set_up
    expect(page).to have_content("#{@training_provider.name} and #{@ratifying_provider.name}")
    expect(page).not_to have_content("#{@training_provider.name} and #{@another_ratifying_provider.name}")
  end

  def and_the_accredited_provider_setting_permissions_flag_is_inactive
    FeatureFlag.deactivate(:accredited_provider_setting_permissions)
  end

  alias_method :and_i_go_to_my_account, :when_i_go_to_my_account
end
