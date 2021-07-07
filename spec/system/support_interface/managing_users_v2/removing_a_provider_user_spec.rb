require 'rails_helper'

RSpec.feature 'Managing provider users v2' do
  include DfESignInHelpers
  include DsiAPIHelper

  scenario 'removing a user from a provider' do
    FeatureFlag.activate(:new_provider_user_flow)

    given_dfe_signin_is_configured
    and_i_am_a_support_user
    and_synced_providers_exist
    and_a_provider_user_exists_for_both_providers

    when_i_visit_the_support_page_for_that_user
    and_i_click_remove_on_the_first_provider
    then_i_should_see_a_confirmation_page

    when_i_click_yes_i_am_sure
    then_i_should_see_a_flash_message
    and_i_should_see_that_the_user_is_no_longer_associated_with_that_provider
  end

  def given_dfe_signin_is_configured
    dsi_api_response(success: true)
  end

  def and_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_synced_providers_exist
    @provider_one = create(:provider, name: 'Example provider one', code: 'ABC', sync_courses: true)
    @provider_two = create(:provider, name: 'Example provider two', code: 'DEF', sync_courses: true)

    create(:course, :open_on_apply, provider: @provider_one)
    create(:course, :open_on_apply, provider: @provider_two)
  end

  def and_a_provider_user_exists_for_both_providers
    @provider_user = create(:provider_user, providers: [@provider_one, @provider_two])
  end

  def when_i_visit_the_support_page_for_that_user
    visit "/support/users/provider/#{@provider_user.id}"
  end

  def and_i_click_remove_on_the_first_provider
    within("[data-qa=\"provider-id-#{@provider_one.id}\"]") do
      click_link 'Remove access'
    end
  end

  def then_i_should_see_a_confirmation_page
    expect(page).to have_content('Are you sure you want to remove this user’s access to Example provider one')
  end

  def when_i_click_yes_i_am_sure
    click_button 'Yes I’m sure - remove access'
  end

  def then_i_should_see_a_flash_message
    expect(page).to have_content 'User no longer has access to Example provider one'
  end

  def and_i_should_see_that_the_user_is_no_longer_associated_with_that_provider
    expect(page).not_to have_selector("[data-qa=\"provider-id-#{@provider_one.id}\"]")
  end
end
