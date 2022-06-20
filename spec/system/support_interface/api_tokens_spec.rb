require 'rails_helper'

RSpec.feature 'Manage API tokens' do
  include DfESignInHelpers

  scenario 'Support creates a token' do
    given_i_am_signed_in
    and_providers_exist
    when_i_visit_the_tokens_page
    and_i_click_on_create_a_token_without_entering_a_provider
    then_i_am_redirected_to_the_support_page
    and_a_warning_message_is_showing

    when_i_select_a_provider
    and_i_click_on_create_a_token
    then_i_should_see_a_new_token
    and_i_am_able_to_connect_to_the_api_using_the_token
    and_the_token_is_visible_on_the_support_page
  end

  def given_i_am_signed_in
    sign_in_as_support_user
  end

  def when_i_visit_the_tokens_page
    visit support_interface_api_tokens_path
  end

  def then_i_am_redirected_to_the_support_page
    expect(page).to have_current_path(support_interface_api_tokens_path)
  end

  def and_a_warning_message_is_showing
    expect(page).to have_content 'Did not select a provider'
  end

  def and_providers_exist
    create(:provider, name: 'Some Provider')
    create(:provider, name: 'Super Provider')
  end

  def when_i_select_a_provider
    select 'Super Provider'
  end

  def and_i_click_on_create_a_token
    click_on 'Create new token'
  end
  alias_method :and_i_click_on_create_a_token_without_entering_a_provider, :and_i_click_on_create_a_token

  def then_i_should_see_a_new_token
    expect(page).to have_content 'Your token is'
  end

  def and_i_am_able_to_connect_to_the_api_using_the_token
    api_token = page.find('code').text
    page.driver.header 'Authorization', "Bearer #{api_token}"

    visit '/api/v1/ping'

    expect(page).to have_content('pong')
  end

  def and_the_token_is_visible_on_the_support_page
    page.driver.browser.authorize('test', 'test')
    visit support_interface_api_tokens_path

    within '.govuk-table' do
      expect(page).to have_content 'Super Provider'
    end
  end
end
