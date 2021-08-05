require 'rails_helper'

RSpec.feature 'Personal details page' do
  include DfESignInHelpers

  before { FeatureFlag.activate(:account_and_org_settings_changes) }

  scenario 'Provider user views their personal details' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_sign_in_to_the_provider_interface

    when_i_go_to_my_account
    then_i_can_see_links_to_my_settings_and_details

    when_i_click_on_personal_details
    then_i_can_see_all_my_details
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_user_exists_in_apply_database
  end

  def when_i_go_to_my_account
    click_on t('page_titles.provider.account')
  end

  def then_i_can_see_links_to_my_settings_and_details
    expect(page).to have_content(t('page_titles.provider.personal_details'))
    expect(page).to have_content(t('page_titles.provider.user_permissions'))
    expect(page).to have_content(t('page_titles.provider.email_notifications'))
  end

  def when_i_click_on_personal_details
    click_on t('page_titles.provider.personal_details')
  end

  def then_i_can_see_all_my_details
    provider_user = ProviderUser.last
    expect(page).to have_content(provider_user.first_name)
    expect(page).to have_content(provider_user.last_name)
    expect(page).to have_content(provider_user.email_address)
  end
end
