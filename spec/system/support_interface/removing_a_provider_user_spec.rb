require 'rails_helper'

RSpec.feature 'Managing provider users v2' do
  include DfESignInHelpers
  include DsiAPIHelper

  scenario 'removing a user from a provider' do
    given_dfe_signin_is_configured
    and_i_am_a_support_user
    and_providers_exist
    and_a_provider_user_exists_for_both_providers

    when_i_visit_the_support_page_for_that_user
    and_i_click_remove_on_the_first_provider
    then_i_should_see_a_confirmation_page

    when_i_click_yes_i_am_sure
    then_i_should_see_a_flash_message
    and_i_should_see_that_the_user_is_no_longer_associated_with_that_provider
    and_the_user_should_receive_an_email_about_being_removed_from_the_provider
  end

  def given_dfe_signin_is_configured
    dsi_api_response(success: true)
  end

  def and_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_providers_exist
    @provider_one = create(:provider, name: 'Example provider one', code: 'ABC')
    @provider_two = create(:provider, name: 'Example provider two', code: 'DEF')

    create(:course, :open, provider: @provider_one)
    create(:course, :open, provider: @provider_two)
  end

  def and_a_provider_user_exists_for_both_providers
    @provider_user = create(:provider_user, providers: [@provider_one, @provider_two])
  end

  def when_i_visit_the_support_page_for_that_user
    visit "/support/users/provider/#{@provider_user.id}"
  end

  def and_i_click_remove_on_the_first_provider
    within("[data-qa=\"provider-id-#{@provider_one.id}\"]") do
      click_link_or_button 'Remove access'
    end
  end

  def then_i_should_see_a_confirmation_page
    expect(page).to have_content('Are you sure you want to remove this user’s access to Example provider one')
  end

  def when_i_click_yes_i_am_sure
    click_link_or_button 'Yes I’m sure - remove access'
  end

  def then_i_should_see_a_flash_message
    expect(page).to have_content 'User no longer has access to Example provider one'
  end

  def and_i_should_see_that_the_user_is_no_longer_associated_with_that_provider
    expect(page).to have_no_css("[data-qa=\"provider-id-#{@provider_one.id}\"]")
  end

  def and_the_user_should_receive_an_email_about_being_removed_from_the_provider
    open_email(@provider_user.email_address)
    expect(current_email.subject).to include("You've been removed from #{@provider_one.name}")
  end
end
