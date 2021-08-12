require 'rails_helper'

RSpec.feature 'Organisation users' do
  include DfESignInHelpers

  before { FeatureFlag.activate(:account_and_org_settings_changes) }

  scenario 'Provider user views their organisation’s users' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_can_manage_users_for_one_provider
    and_i_cannot_manage_users_for_another_provider
    and_i_sign_in_to_the_provider_interface

    when_i_go_to_organisation_settings
    then_i_see_users_links_for_both_providers

    when_i_view_users_for(@manage_users_provider)
    then_i_see_a_list_of_users_for(@manage_users_provider)

    when_i_click_on_the(@first_manageable_user)
    then_i_see_personal_details_for(@first_manageable_user)
    and_i_can_see_their_user_permissions
    and_i_can_see_change_links

    when_i_go_to_organisation_settings
    and_i_view_users_for(@read_only_provider)
    then_i_see_a_list_of_users_for(@read_only_provider)

    when_i_click_on_the(@first_unmanageable_user)
    then_i_see_personal_details_for(@first_unmanageable_user)
    and_i_can_see_their_user_permissions
    and_i_cannot_see_change_links
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

    create_list(:provider_user, 3, providers: [@manage_users_provider])
    @first_manageable_user = @manage_users_provider.provider_users.where.not(id: @provider_user.id).order(:first_name, :last_name).first
  end

  def and_i_cannot_manage_users_for_another_provider
    @read_only_provider = create(:provider, :with_signed_agreement, code: 'DEF')
    create(:provider_permissions, provider_user: @provider_user, provider: @read_only_provider)

    create_list(:provider_user, 3, providers: [@read_only_provider])
    @first_unmanageable_user = @read_only_provider.provider_users.where.not(id: @provider_user.id).order(:first_name, :last_name).first
  end

  def when_i_go_to_organisation_settings
    click_on 'Organisation settings', match: :first
  end

  def then_i_see_users_links_for_both_providers
    expect(page).to have_link("Users #{@manage_users_provider.name}")
    expect(page).to have_link("Users #{@read_only_provider.name}")
  end

  def when_i_view_users_for(provider)
    click_on "Users #{provider.name}"
  end

  alias_method :and_i_view_users_for, :when_i_view_users_for

  def then_i_see_a_list_of_users_for(provider)
    expect(page).to have_selector('span', text: provider.name)
    expect(page).to have_selector('h1', text: 'Users')
    users = provider.provider_users
    users.each do |user|
      expect(page).to have_selector('h2 > a', text: user.full_name)
    end
  end

  def when_i_click_on_the(user)
    click_on user.full_name
  end

  def then_i_see_personal_details_for(user)
    expect(page).to have_selector('h1', text: user.full_name)
    expect(page).to have_selector('h2', text: 'Personal details')
    expect(page).to have_selector('.govuk-summary-list__value', text: user.first_name)
    expect(page).to have_selector('.govuk-summary-list__value', text: user.last_name)
    expect(page).to have_selector('.govuk-summary-list__value', text: user.email_address)
  end

  def and_i_can_see_their_user_permissions
    expect(page).to have_selector('h2', text: 'User permissions')
    expect(page).to have_selector('.govuk-summary-list__row', text: 'Manage users No')
    expect(page).to have_selector('.govuk-summary-list__row', text: 'Manage organisation permissions No')
    expect(page).to have_selector('.govuk-summary-list__row', text: 'Set up interviews No')
    expect(page).to have_selector('.govuk-summary-list__row', text: 'Make offers and reject applications No')
    expect(page).to have_selector('.govuk-summary-list__row', text: 'View criminal convictions and professional misconduct No')
    expect(page).to have_selector('.govuk-summary-list__row', text: 'View sex, disability and ethnicity information No')
  end

  def and_i_can_see_change_links
    expect(page).to have_link('Change Set up interviews')
  end

  def and_i_cannot_see_change_links
    expect(page).not_to have_link('Change Set up interviews')
  end
end
