require 'rails_helper'

RSpec.feature 'Managing provider users v2' do
  include DfESignInHelpers
  include DsiAPIHelper

  scenario 'adding provider to an existing provider user', with_audited: true do
    given_dfe_signin_is_configured
    and_i_am_a_support_user
    and_synced_providers_exist
    and_a_provider_user_exists_for_the_first_provider

    when_i_visit_the_second_provider_page
    and_i_click_on_users
    then_i_should_not_see_the_provider_user_listed

    when_i_click_add_user
    and_i_enter_the_users_details
    and_i_check_permissions
    and_i_submit_the_form
    then_i_should_see_the_provider_user_has_been_successfully_added
    and_the_provider_user_is_now_associated_with_both_providers
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

  def and_a_provider_user_exists_for_the_first_provider
    @provider_user = create(:provider_user, providers: [@provider_one])
  end

  def when_i_visit_the_second_provider_page
    visit support_interface_provider_path(@provider_two)
  end

  def and_i_click_on_users
    click_on 'Users'
  end

  def then_i_should_not_see_the_provider_user_listed
    expect(page).not_to have_content("#{@provider_user.first_name} #{@provider_user.last_name}")
  end

  def when_i_click_add_user
    click_on 'Add user'
  end

  def and_i_enter_the_users_details
    fill_in 'support_interface_create_single_provider_user_form[email_address]', with: @provider_user.email_address
    fill_in 'support_interface_create_single_provider_user_form[first_name]', with: @provider_user.first_name
    fill_in 'support_interface_create_single_provider_user_form[last_name]', with: @provider_user.last_name
  end

  def and_i_check_permissions
    check 'Manage users'
    check 'Manage organisational permissions'
    check 'Set up interviews'
  end

  def and_i_submit_the_form
    click_on 'Add user'
  end

  def then_i_should_see_the_provider_user_has_been_successfully_added
    expect(page).to have_content("User #{@provider_user.first_name} #{@provider_user.last_name} added")
  end

  def and_the_provider_user_is_now_associated_with_both_providers
    within '.govuk-table__body' do
      expect(page).to have_content(@provider_one.name)
      expect(page).to have_content(@provider_two.name)
    end
  end
end
