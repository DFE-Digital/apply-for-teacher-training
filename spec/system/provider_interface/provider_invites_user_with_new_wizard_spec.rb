require 'rails_helper'

RSpec.feature 'Provider invites a new provider user using wizard interface' do
  include DfESignInHelpers
  include DsiAPIHelper

  scenario 'Provider sends invite to user' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_can_manage_applications_for_two_providers
    and_i_sign_in_to_the_provider_interface

    when_i_try_to_visit_the_users_page
    then_i_see_a_403_page
    when_i_visit_the_invite_user_wizard
    then_i_see_a_404_page

    and_i_can_manage_users_for_two_providers
    and_i_sign_in_again_to_the_provider_interface

    when_i_click_on_the_users_link
    and_i_click_invite_user
    then_i_see_the_basic_details_form

    when_i_press_continue
    then_i_see_validation_errors_for_names_and_email_address

    when_i_fill_in_email_address_and_name
    and_i_press_continue
    then_i_see_the_select_organisations_form
    and_i_press_continue
    and_i_see_an_error_telling_me_to_select_a_provider
    and_select_organisations_only_lists_providers_i_can_manage

    when_i_select_one_provider
    and_i_press_continue
    then_i_see_the_select_permissions_form_for_selected_provider

    when_i_press_continue
    then_i_see_validation_errors_for_extra_permissions

    when_i_select_make_decisions_permission
    and_i_press_continue
    then_i_see_the_confirm_page

    when_i_click_to_change_the_users_name
    then_i_can_see_the_details_form
    when_i_fill_in_a_new_name
    and_i_press_continue
    then_i_see_the_confirm_page_with_the_new_name

    when_i_click_to_change_the_permissions_for_another_provider
    then_i_can_see_the_permissions_form
    when_i_change_permissions
    and_i_press_continue
    then_i_see_the_confirm_page_with_the_new_permissions

    when_i_commit_changes
    then_i_see_the_new_user_on_the_index_page
    and_new_user_gets_an_invitation_email
  end

  def when_i_try_to_visit_the_users_page
    visit provider_interface_provider_users_path
  end

  def then_i_see_a_403_page
    expect(page).to have_content('Access denied')
  end

  def then_i_see_a_404_page
    expect(page).to have_content('Page not found')
  end

  def when_i_visit_the_invite_user_wizard
    visit provider_interface_edit_invitation_basic_details_path
  end

  def when_i_click_on_the_users_link
    click_on(t('page_titles.provider.organisation_settings'))
    click_on(t('page_titles.provider.users'))
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_can_manage_applications_for_two_providers
    provider_user_exists_in_apply_database
    @provider_user = ProviderUser.find_by(dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    @provider = Provider.find_by(code: 'ABC')
    @another_provider = Provider.find_by(code: 'DEF')
  end

  def and_i_can_manage_users_for_two_providers
    @view_only_provider = create(:provider, :with_signed_agreement)
    @provider_user.providers << @view_only_provider
    @provider_user.provider_permissions.find_by(provider: @provider).update(manage_users: true)
    @provider_user.provider_permissions.find_by(provider: @another_provider).update(manage_users: true)
  end

  def and_i_sign_in_again_to_the_provider_interface
    click_link('Sign out')
    and_i_sign_in_to_the_provider_interface
  end

  def and_i_click_invite_user
    click_on 'Invite user'
  end

  def then_i_see_the_basic_details_form
    expect(page).to have_content('Basic details')
  end

  def when_i_fill_in_email_address_and_name
    fill_in 'Email address', with: 'Ed@Example.Com'
    fill_in 'First name', with: 'Ed'
    fill_in 'Last name', with: 'Ucator'
  end

  def and_i_press_continue
    click_on t('continue')
  end
  alias_method :when_i_press_continue, :and_i_press_continue

  def then_i_see_validation_errors_for_names_and_email_address
    expect(page).to have_content('Enter the user’s first name')
    expect(page).to have_content('Enter the user’s last name')
    expect(page).to have_content('Enter the user’s email address')
  end

  def then_i_see_the_select_organisations_form
    expect(page).to have_content('Select organisations this user will have access to')
  end

  def and_i_see_an_error_telling_me_to_select_a_provider
    expect(page).to have_content('Error: Select which organisations this user will have access to')
  end

  def and_select_organisations_only_lists_providers_i_can_manage
    expect(page).not_to have_content(@view_only_provider.name)
  end

  def when_i_select_one_provider
    check 'Another Provider'
  end

  def then_i_see_the_select_permissions_form_for_selected_provider
    expect(page).to have_content('Select permissions')
    choose 'Extra permissions'
  end

  def then_i_see_validation_errors_for_extra_permissions
    expect(page).to have_content('Select extra permissions')
  end

  def when_i_select_make_decisions_permission
    check 'Set up interviews'
    check 'Make decisions'
  end

  def then_i_see_the_confirm_page
    expect(page).to have_content 'Check permissions before you invite user'
    expect(page).to have_content 'Ed'
    expect(page).to have_content 'Ucator'
    expect(page).to have_content 'ed@example.com'
    expect(page).not_to have_content 'Example Provider'
    expect(page).to have_content 'Another Provider'
    expect(page).to have_content 'Set up interviews'
    expect(page).to have_content 'Make decisions'
    expect(page).not_to have_content 'Manage users'
    expect(page).not_to have_content 'Access diversity information'
  end

  def when_i_click_to_change_the_users_name
    all('.govuk-summary-list__actions')[0].click_link 'Change'
  end

  def then_i_can_see_the_details_form
    expect(page).to have_selector("input[value='Ed']")
    expect(page).to have_selector("input[value='Ucator']")
    expect(page).to have_selector("input[value='ed@example.com']")
  end

  def when_i_fill_in_a_new_name
    fill_in 'First name', with: 'Eddy'
  end

  def then_i_see_the_confirm_page_with_the_new_name
    expect(page).to have_content 'Check permissions before you invite user'
    expect(page).to have_content 'Eddy'
    expect(page).to have_content 'Ucator'
    expect(page).to have_content 'ed@example.com'
  end

  def when_i_click_to_change_the_permissions_for_another_provider
    all('.govuk-summary-list__actions')[4].click_link 'Change'
  end

  def then_i_can_see_the_permissions_form
    expect(page).to have_content 'Select permissions'
    choose 'Extra permissions'
  end

  def when_i_change_permissions
    check 'Manage users'
  end

  def then_i_see_the_confirm_page_with_the_new_permissions
    expect(page).to have_content 'Another Provider'
    expect(page).to have_content 'Set up interviews'
    expect(page).to have_content 'Make decisions'
    expect(page).to have_content 'Manage users'
  end

  def when_i_commit_changes
    dsi_api_response(success: true)
    click_button 'Invite user'
  end

  def then_i_see_the_new_user_on_the_index_page
    expect(page).to have_content('User successfully invited')
    expect(page).to have_content('Eddy Ucator')
  end

  def and_new_user_gets_an_invitation_email
    open_email('ed@example.com')
    expect(current_email.subject).to have_content t('provider_mailer.account_created.subject')
  end
end
