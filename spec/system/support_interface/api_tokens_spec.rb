require 'rails_helper'

RSpec.feature 'Manage API tokens' do
  scenario 'Support creates a token' do
    given_i_am_signed_in
    when_i_visit_the_tokens_page
    and_i_click_on_create_a_token
    then_i_should_see_a_new_token
    and_i_am_able_to_connect_to_the_api_using_the_token
  end

  def given_i_am_signed_in
    page.driver.browser.authorize('test', 'test')
  end

  def when_i_visit_the_tokens_page
    visit support_interface_api_tokens_path
  end

  def and_i_click_on_create_a_token
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
end
