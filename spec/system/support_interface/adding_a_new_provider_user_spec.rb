require 'rails_helper'

RSpec.feature 'Managing provider users v2' do
  include DfESignInHelpers
  include DsiAPIHelper

  scenario 'adding a new provider user', with_audited: true do
    given_dfe_signin_is_configured
    and_i_am_a_support_user
    and_providers_exist

    when_i_visit_the_support_console
    and_i_navigate_to_provider_users_page
    and_i_filter_providers_by_synced_courses
    then_i_see_synced_providers

    when_i_click_on_a_synced_provider
    and_i_click_on_users
    and_i_click_add_user
    then_i_should_see_the_add_user_form

    when_i_submit_the_form
    then_i_see_blank_validation_errors

    when_i_enter_the_users_email_and_name
    and_i_check_permission_to_manage_users
    and_i_check_permission_to_set_up_interviews
    and_i_check_permission_to_manage_organisations
    and_i_check_permission_to_view_safeguarding_information
    and_i_check_permission_to_make_decisions
    and_i_check_permission_to_view_diversity_information
    and_i_submit_the_form
    then_i_should_see_the_provider_user_has_been_successfully_added
    and_the_user_should_be_sent_a_welcome_email
  end

  def given_dfe_signin_is_configured
    dsi_api_response(success: true)
  end

  def and_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_providers_exist
    @provider = create(:provider, name: 'Example provider', code: 'ABC', sync_courses: true)
    create(:course, :open_on_apply, provider: @provider)
    @provider2 = create(:provider, name: 'Another provider', code: 'DEF')
    create(:course, :open_on_apply, provider: @provider2)
    create(:provider, name: 'Not shown provider', code: 'GHI')
  end

  def then_i_see_synced_providers
    expect(page).to have_content 'Example provider'
    expect(page).to have_content 'Another provider'
    expect(page).not_to have_content 'Not shown provider'
  end

  def when_i_visit_the_support_console
    visit support_interface_path
  end

  def and_i_navigate_to_provider_users_page
    click_link 'Providers'
  end

  def and_i_filter_providers_by_synced_courses
    check 'With courses'
    click_on 'Apply filters'
  end

  def and_i_click_add_user
    click_on 'Add user'
  end

  def when_i_click_on_a_synced_provider
    click_on 'Example provider (ABC)'
  end

  def and_i_click_on_users
    click_on 'Users'
  end

  def and_i_submit_the_form
    when_i_submit_the_form
  end

  def and_i_check_permission_to_manage_users
    check 'Manage users'
  end

  def and_i_check_permission_to_set_up_interviews
    check 'Set up interviews'
  end

  def and_i_check_permission_to_manage_organisations
    check 'Manage organisational permissions'
  end

  def and_i_check_permission_to_view_safeguarding_information
    check 'Access safeguarding information'
  end

  def and_i_check_permission_to_make_decisions
    check 'Make decisions'
  end

  def and_i_check_permission_to_view_diversity_information
    check 'Access diversity information'
  end

  def when_i_submit_the_form
    click_on 'Add user'
  end

  def then_i_see_blank_validation_errors
    expect(page).to have_content 'Enter an email address'
    expect(page).to have_content 'Enter a first name'
    expect(page).to have_content 'Enter a last name'
  end

  def when_i_enter_the_users_email_and_name
    fill_in 'support_interface_create_single_provider_user_form[email_address]', with: 'harrison@example.com'
    fill_in 'support_interface_create_single_provider_user_form[first_name]', with: 'Harrison'
    fill_in 'support_interface_create_single_provider_user_form[last_name]', with: 'Bergeron'
  end

  def and_i_enter_the_users_email_and_name
    when_i_enter_the_users_email_and_name
  end

  def then_i_should_see_the_add_user_form
    expect(page).to have_content('Add user to Example provider')
  end

  def then_i_should_see_the_provider_user_has_been_successfully_added
    expect(page).to have_content('User Harrison Bergeron added')
  end

  def when_i_filter_the_list_of_provider_users
    expect(page).to have_field('Has signed in')

    fill_in :q, with: 'harrison'
    check 'Never signed in'
    click_on 'Apply filters'
  end

  def and_i_should_see_the_user_i_created
    expect(page).to have_content('harrison@example.com')
  end

  def when_i_filter_the_list_of_provider_users_by_id
    @new_user = ProviderUser.find_by_email_address('harrison@example.com')
    fill_in :q, with: @new_user.id
    click_on 'Apply filters'
  end

  def and_the_user_should_be_sent_a_welcome_email
    open_email('harrison@example.com')
    expect(current_email.subject).to have_content t('provider_mailer.account_created.subject')
  end
end
