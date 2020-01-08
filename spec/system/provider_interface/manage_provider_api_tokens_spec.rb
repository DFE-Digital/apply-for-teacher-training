require 'rails_helper'

RSpec.feature 'Manage API tokens' do
  include DfESignInHelpers

  scenario 'Provider user creates a token' do
    given_i_am_signed_in
    when_i_visit_the_tokens_page
    and_i_click_on_create_a_token
    then_i_should_see_a_new_token
    and_i_am_able_to_connect_to_the_api_using_the_token
    and_the_token_is_visible_on_the_tokens_page
  end

  def given_i_am_signed_in
    provider_user = provider_user_exists_in_apply_database
    create(:provider, name: 'Super Provider', code: 'ABC', provider_users: [provider_user])
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
  end

  def when_i_visit_the_tokens_page
    visit provider_interface_api_tokens_path
  end

  def and_i_click_on_create_a_token
    select 'Super Provider'
    click_on 'Create new token'
  end

  def then_i_should_see_a_new_token
    expect(page).to have_content 'Your token is'
  end

  def and_i_am_able_to_connect_to_the_api_using_the_token
    api_token = page.find('code').text
    page.driver.header 'Authorization', "Bearer #{api_token}"

    visit '/api/v1/ping'

    expect(page).to have_content('pong')
  end

  def and_the_token_is_visible_on_the_tokens_page
    page.driver.browser.authorize('test', 'test')
    visit provider_interface_api_tokens_path

    within '.govuk-table' do
      expect(page).to have_content 'Super Provider'
    end
  end
end
