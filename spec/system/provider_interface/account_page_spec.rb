require 'rails_helper'

RSpec.feature 'Viewing the provider user account page' do
  include DfESignInHelpers

  scenario 'Provider user visits their account page with various permissions' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_sign_in_to_the_provider_interface

    when_i_go_to_my_account
    then_i_can_see_links_to_my_profile_and_notifications
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_user_exists_in_apply_database
  end

  def when_i_go_to_my_account
    click_on t('page_titles.provider.account')
  end

  def then_i_can_see_links_to_my_profile_and_notifications
    expect(page).to have_content(t('page_titles.provider.profile'))
    expect(page).to have_content(t('page_titles.provider.notifications'))
  end
end
