require 'rails_helper'

RSpec.describe 'Provider user unsubscribes from emails' do
  include DfESignInHelpers

  scenario 'Provider user is not logged in and clicks the unsubscribe link' do
    given_i_am_a_provider_user
    when_i_visit_the_unsubscribe_link
    then_i_see_that_have_unsubscribed
  end

  scenario 'Provider user is logged in and clicks the unsubscribe link' do
    given_i_am_a_provider_user
    and_i_sign_in_to_the_provider_interface
    when_i_visit_the_unsubscribe_link
    then_i_see_that_have_unsubscribed
  end

  scenario 'Provider user visits link with invalid token' do
    given_i_am_a_provider_user
    and_i_visit_a_bad_unsubscribe_link
    then_i_see_a_404
  end

  scenario 'Provider user has multiple tokens generated' do
    given_i_am_a_provider_user
    and_i_have_generated_multiple_tokens
    when_i_visit_the_unsubscribe_link_using_the_first_token
    then_i_see_that_have_unsubscribed

    when_i_visit_the_unsubscribe_link_using_the_second_token
    then_i_see_that_have_unsubscribed
  end

private

  def given_i_am_a_provider_user
    @provider_user = create(:provider_user, :with_dfe_sign_in, :with_set_up_interviews)
    user_exists_in_dfe_sign_in(email_address: @provider_user.email_address)
  end

  def when_i_visit_the_unsubscribe_link
    @token = @provider_user.generate_token_for :unsubscribe_link
    visit provider_interface_unsubscribe_from_emails_path(token: @token)
  end

  def then_i_see_that_have_unsubscribed
    expect(page).to have_current_path(provider_interface_unsubscribe_from_emails_path(token: @token))
    expect(page).to have_element(:h1, text: 'You have successfully unsubscribed')
    expect(page).to have_element(:p, text: 'You will still receive essential updates about applications.')
    expect(@provider_user.notification_preferences.marketing_emails).to be(false)
  end

  def and_i_visit_a_bad_unsubscribe_link
    visit provider_interface_unsubscribe_from_emails_path(token: 'random-token')
  end

  def then_i_see_a_404
    expect(page).to have_content 'Page not found'
  end

  def and_i_have_generated_multiple_tokens
    @token_1 = @provider_user.generate_token_for :unsubscribe_link
    @token_2 = @provider_user.generate_token_for :unsubscribe_link
  end

  def when_i_visit_the_unsubscribe_link_using_the_first_token
    @token = @token_1
    visit provider_interface_unsubscribe_from_emails_path(token: @token)
  end

  def when_i_visit_the_unsubscribe_link_using_the_second_token
    @token = @token_2
    visit provider_interface_unsubscribe_from_emails_path(token: @token)
  end
end
