require 'rails_helper'

RSpec.feature 'User permissions page' do
  include DfESignInHelpers

  before { FeatureFlag.activate(:account_and_org_settings_changes) }

  scenario 'Provider views their own user permissions' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_belong_to_two_providers
    and_i_sign_in_to_the_provider_interface

    when_i_click_on_the_account_profile_link
    then_i_see_the_user_permissions_page_with_my_providers
    and_i_see_my_permissions_for_the_alphabetically_first_provider
    and_i_see_my_permissions_for_the_alphabetically_second_provider
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_belong_to_two_providers
    provider_user_exists_in_apply_database
    @provider_user = ProviderUser.find_by(dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    @first_provider = Provider.find_by(code: 'ABC')
    @second_provider = Provider.find_by(code: 'DEF')
    ProviderPermissions.find_by(provider: @second_provider, provider_user: @provider_user).update(view_diversity_information: true)
  end

  def when_i_click_on_the_account_profile_link
    click_on('Your account')
    click_on('Your user permissions')
  end

  def then_i_see_the_user_permissions_page_with_my_providers
    expect(element_text(selector: 'h2', index: 1)).to eq('Access to organisations')
    within(element(selector: '.govuk-summary-list__value', index: 0)) do
      expect(page).to have_selector('p', text: @first_provider.name)
      expect(page).to have_selector('p', text: @second_provider.name)
    end
  end

  def and_i_see_my_permissions_for_the_alphabetically_first_provider
    expect(element_text(selector: 'h2', index: 2)).to eq("Permissions for #{@second_provider.name}")
    within(element(selector: '.govuk-summary-list', index: 1)) do
      expect(element_text(selector: '.govuk-summary-list__key', index: 0)).to eq('Manage users')
      expect(element_text(selector: '.govuk-summary-list__key', index: 1)).to eq('Manage organisation permissions')
      expect(element_text(selector: '.govuk-summary-list__key', index: 2)).to eq('Set up interviews')
      expect(element_text(selector: '.govuk-summary-list__key', index: 3)).to eq('Make offers and reject applications')
      expect(element_text(selector: '.govuk-summary-list__key', index: 4)).to eq('View criminal convictions and professional misconduct')
      expect(element_text(selector: '.govuk-summary-list__key', index: 5)).to eq('View sex, disability and ethnicity information')
      expect(element_text(selector: '.govuk-summary-list__value', index: 5)).to include('This user permission is affected by organisation permissions.')
    end
  end

  def and_i_see_my_permissions_for_the_alphabetically_second_provider
    expect(element_text(selector: 'h2', index: 3)).to eq("Permissions for #{@first_provider.name}")
    within(element(selector: '.govuk-summary-list', index: 2)) do
      expect(element_text(selector: '.govuk-summary-list__key', index: 0)).to eq('Manage users')
      expect(element_text(selector: '.govuk-summary-list__key', index: 1)).to eq('Manage organisation permissions')
      expect(element_text(selector: '.govuk-summary-list__key', index: 2)).to eq('Set up interviews')
      expect(element_text(selector: '.govuk-summary-list__key', index: 3)).to eq('Make offers and reject applications')
      expect(element_text(selector: '.govuk-summary-list__key', index: 4)).to eq('View criminal convictions and professional misconduct')
      expect(element_text(selector: '.govuk-summary-list__key', index: 5)).to eq('View sex, disability and ethnicity information')
    end
  end

  def element_text(selector:, index:)
    element(selector: selector, index: index).text.squish
  end

  def element(selector:, index:)
    all(selector)[index]
  end
end
