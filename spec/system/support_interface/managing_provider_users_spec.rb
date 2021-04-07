require 'rails_helper'

RSpec.feature 'Managing provider users' do
  include DfESignInHelpers
  include DsiAPIHelper

  scenario 'creating a new provider user', with_audited: true do
    given_dfe_signin_is_configured
    and_i_am_a_support_user
    and_providers_exist

    when_i_visit_the_support_console
    and_i_navigate_to_provider_users_page
    then_i_should_see_a_csv_export_button

    when_i_click_the_add_user_link
    then_i_see_synced_providers

    when_i_enter_an_existing_email
    and_i_click_add_user
    then_i_see_an_error

    and_i_enter_the_users_email_and_name
    and_i_select_a_provider
    and_i_check_permission_to_manage_users
    and_i_check_permission_to_manage_organisations
    and_i_check_permission_to_view_safeguarding_information
    and_i_check_permission_to_make_decisions
    and_i_check_permission_to_view_diversity_information
    and_i_click_add_user

    then_i_should_see_the_list_of_provider_users
    when_i_filter_the_list_of_provider_users
    and_i_should_see_the_user_i_created

    when_i_filter_the_list_of_provider_users_by_id
    and_i_should_see_the_user_i_created
    and_the_user_should_be_sent_a_welcome_email

    and_i_click_on_that_user

    when_i_add_them_to_another_organisation
    then_i_see_that_they_have_been_added_to_that_organisation
    and_they_should_be_able_to_manage_users
    and_they_should_be_able_to_manage_organisations
    and_they_should_be_able_to_view_safeguarding_information
    and_they_should_be_able_to_make_decisions
    and_they_should_be_able_to_view_diversity_information

    when_i_click_to_change_their_permissions
    and_i_remove_manage_users_permissions
    and_i_remove_manage_organisations_permissions
    and_i_remove_access_to_a_provider
    and_i_click_update_permissions
    then_they_should_not_be_able_to_manage_users
    and_they_should_not_be_able_to_manage_organisations
    and_they_should_not_have_access_to_the_removed_provider

    when_i_click_the_audit_trail_tab
    then_i_should_see_the_audit_trail_for_that_user_record
  end

  def given_dfe_signin_is_configured
    set_dsi_api_response(success: true)
  end

  def and_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_providers_exist
    @provider = create(:provider, name: 'Example provider', code: 'ABC', sync_courses: true)
    create(:provider, name: 'Another provider', code: 'DEF', sync_courses: true)
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
    click_link 'Provider users'
  end

  def then_i_should_see_a_csv_export_button
    expect(page).to have_link('Download active provider users (CSV)')
  end

  def and_i_select_a_provider
    check 'Example provider (ABC)'
  end

  def and_i_check_permission_to_manage_users
    within(permissions_checkboxes_for_provider(@provider)) do
      check 'Manage users'
    end
  end

  def and_i_check_permission_to_manage_organisations
    within(permissions_checkboxes_for_provider(@provider)) do
      check 'Manage organisational permissions'
    end
  end

  def and_i_check_permission_to_view_safeguarding_information
    within(permissions_checkboxes_for_provider(@provider)) do
      check 'Access safeguarding information'
    end
  end

  def and_i_check_permission_to_make_decisions
    within(permissions_checkboxes_for_provider(@provider)) do
      check 'Make decisions'
    end
  end

  def and_i_check_permission_to_view_diversity_information
    within(permissions_checkboxes_for_provider(@provider)) do
      check 'Access diversity information'
    end
  end

  def when_i_click_the_add_user_link
    click_link 'Add provider user'
  end

  def when_i_enter_an_existing_email
    create(:provider_user, email_address: 'existing@example.org')
    fill_in 'support_interface_provider_user_form[email_address]', with: 'Existing@example.org'
  end

  def then_i_see_an_error
    expect(page).to have_content 'This email address is already in use'
  end

  def and_i_enter_the_users_email_and_name
    fill_in 'support_interface_provider_user_form[email_address]', with: 'harrison@example.com'
    fill_in 'support_interface_provider_user_form[first_name]', with: 'Harrison'
    fill_in 'support_interface_provider_user_form[last_name]', with: 'Bergeron'
  end

  def and_i_click_add_user
    click_button 'Add provider user'
  end

  def then_i_should_see_the_list_of_provider_users
    expect(page).to have_title('Provider users')
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

  def and_i_click_on_that_user
    click_link 'Harrison Bergeron'
  end

  def when_i_add_them_to_another_organisation
    click_link 'Change permissions'
    check 'Another provider (DEF)'
    click_button 'Update permissions'
  end

  def then_i_see_that_they_have_been_added_to_that_organisation
    expect(page).to have_content('Example provider (ABC)')
    expect(page).to have_content('Another provider (DEF)')
  end

  def when_i_click_the_audit_trail_tab
    click_on 'History'
  end

  def then_i_should_see_the_audit_trail_for_that_user_record
    expect(page).to have_content 'Create Provider User'
    expect(page).to have_content 'email_address harrison@example.com'
  end

  def and_they_should_be_able_to_manage_users
    within(permissions_summary_for_provider(@provider)) do
      expect(page).to have_content('Manage users')
    end
  end

  def and_they_should_be_able_to_manage_organisations
    within(permissions_summary_for_provider(@provider)) do
      expect(page).to have_content('Manage organisational permissions')
    end
  end

  def and_they_should_be_able_to_view_safeguarding_information
    within(permissions_summary_for_provider(@provider)) do
      expect(page).to have_content('Access safeguarding information')
    end
  end

  def and_they_should_be_able_to_make_decisions
    within(permissions_summary_for_provider(@provider)) do
      expect(page).to have_content('Make decisions')
    end
  end

  def and_they_should_be_able_to_view_diversity_information
    within(permissions_summary_for_provider(@provider)) do
      expect(page).to have_content('Access diversity information')
    end
  end

  def when_i_click_to_change_their_permissions
    click_on 'Change permissions'
  end

  def and_i_remove_manage_users_permissions
    within(permissions_checkboxes_for_provider(@provider)) do
      uncheck 'Manage users'
    end
  end

  def and_i_remove_manage_organisations_permissions
    within(permissions_checkboxes_for_provider(@provider)) do
      uncheck 'Manage organisational permissions'
    end
  end

  def and_i_remove_access_to_a_provider
    uncheck 'Another provider (DEF)'
  end

  def and_i_click_update_permissions
    click_on 'Update permissions'
  end

  def then_they_should_not_be_able_to_manage_users
    within(permissions_summary_for_provider(@provider)) do
      expect(page).not_to have_content('Manage users')
    end
  end

  def and_they_should_not_be_able_to_manage_organisations
    within(permissions_summary_for_provider(@provider)) do
      expect(page).not_to have_content('Manage organisational permissions')
    end
  end

  def and_they_should_not_have_access_to_the_removed_provider
    expect(page).to have_content('Example provider (ABC)')
    expect(page).not_to have_content('Another provider (DEF)')
  end

  def permissions_summary_for_provider(provider)
    "#provider-#{provider.id}-enabled-permissions"
  end

  def permissions_checkboxes_for_provider(provider)
    "#support-interface-provider-user-form-provider-permissions-forms-#{provider.id}-active-true-conditional"
  end
end
