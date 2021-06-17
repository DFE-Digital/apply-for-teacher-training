require 'rails_helper'

RSpec.feature 'Viewing organisational permissions' do
  include DfESignInHelpers

  scenario 'Provider user uses their account page with various permissions' do
    given_i_am_a_provider_user_with_dfe_sign_in

    and_i_sign_in_to_the_provider_interface

    given_i_can_manage_multiple_organisations_that_do_not_have_permissions_set_up

    when_i_go_to_my_account
    then_i_cannot_see_organisational_permissions

    when_i_set_up_permissions_for_a_provider
    and_i_go_to_my_account
    then_i_can_see_organisational_permissions

    when_i_go_to_organisational_permissions
    then_i_can_see_organisations_with_setup_permissions
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_user_exists_in_apply_database
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

    @training_provider = Provider.find_by(code: 'ABC')
    @ratifying_provider = Provider.find_by(code: 'DEF')
    @another_ratifying_provider = create(:provider, :with_signed_agreement, code: 'GHI', name: 'Another Example Provider')
    @provider_user.providers << @another_ratifying_provider

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
    expect(page).to have_content("#{@training_provider.name}")
    expect(page).to have_content("#{@ratifying_provider.name}")
    expect(page).not_to have_content("#{@another_ratifying_provider.name}")
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

  alias_method :and_i_go_to_my_account, :when_i_go_to_my_account
end
