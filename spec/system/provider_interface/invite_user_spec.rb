require 'rails_helper'

RSpec.describe 'Provider user invitation' do
  include DfESignInHelpers
  include DsiAPIHelper

  scenario 'Provider invites user' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_sign_in_to_the_provider_interface
    and_i_go_to_the_users_page
    then_i_cannot_see_the_invite_user_button

    given_i_can_manage_users
    and_i_go_to_the_users_page
    then_i_can_see_the_invite_user_button

    when_i_click_on_invite_user
    then_i_see_a_personal_details_form

    when_i_fill_in_personal_details_with_an_email_that_already_exists
    and_i_click_continue
    then_i_see_a_duplicate_email_validation_error

    when_i_fill_in_unique_personal_details
    and_i_click_continue
    then_i_see_a_permissions_form

    when_i_select_some_permissions
    and_i_click_continue
    then_i_see_a_check_page
    and_i_see_the_specified_personal_details
    and_i_see_the_selected_permissions

    when_i_click_to_change_the_first_name
    then_i_see_a_personal_details_form

    when_i_change_the_first_name
    and_i_click_continue
    then_i_see_a_check_page
    and_i_see_the_first_name_has_been_updated

    when_i_commit_the_changes
    then_i_see_a_success_message
    and_the_new_user_appears_in_the_user_list
    and_the_new_user_gets_an_invitation_email
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in

    @provider = create(:provider, code: 'ABC')
    @provider_user = create(
      :provider_user,
      providers: [@provider],
      dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
      email_address: 'email@provider.ac.uk',
    )
  end

  def and_i_go_to_the_users_page
    click_link_or_button 'Organisation settings', match: :first
    click_link_or_button 'Users', match: :first
  end

  def then_i_cannot_see_the_invite_user_button
    expect(page).to have_no_link('Add user')
  end

  def given_i_can_manage_users
    @provider_user.provider_permissions.update_all(manage_users: true)
  end

  def then_i_can_see_the_invite_user_button
    expect(page).to have_link('Add user')
  end

  def when_i_click_on_invite_user
    click_link_or_button 'Add user'
  end

  def then_i_see_a_personal_details_form
    expect(page).to have_css('h1', text: 'Personal details')
  end

  def when_i_fill_in_personal_details_with_an_email_that_already_exists
    fill_in 'First name', with: 'Johnathy'
    fill_in 'Last name', with: 'Smithinson'
    fill_in 'Email address', with: 'email@provider.ac.uk'
  end

  def and_i_click_continue
    click_link_or_button 'Continue'
  end

  def then_i_see_a_duplicate_email_validation_error
    expect(page).to have_content("A user with this email address already has access to #{@provider.name}")
  end

  def when_i_fill_in_unique_personal_details
    fill_in 'First name', with: 'Johnathy'
    fill_in 'Last name', with: 'Smithinson'
    fill_in 'Email address', with: 'john.smith@example.com'
  end

  def then_i_see_a_permissions_form
    expect(page).to have_css('h1', text: 'User permissions')
  end

  def when_i_select_some_permissions
    check 'Manage users'
    check 'View sex, disability and ethnicity information'
  end

  def then_i_see_a_check_page
    expect(page).to have_css('h1', text: 'Check permissions and add user')
  end

  def and_i_see_the_specified_personal_details
    expect(page).to have_css('h2', text: 'Personal details')
    expect(page).to have_css('.govuk-summary-list__row', text: 'First name Johnathy')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Last name Smithinson')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Email address john.smith@example.com')
  end

  def and_i_see_the_selected_permissions
    expect(page).to have_css('h2', text: 'User permissions')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage users Yes')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage organisation permissions No')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage interviews No')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Send offers, invitations and rejections No')
    expect(page).to have_css('.govuk-summary-list__row', text: 'View criminal convictions and professional misconduct No')
    expect(page).to have_css('.govuk-summary-list__row', text: 'View sex, disability and ethnicity information Yes')
  end

  def when_i_click_to_change_the_first_name
    click_link_or_button 'Change First name'
  end

  def when_i_change_the_first_name
    fill_in 'First name', with: 'Jack'
  end

  def and_i_see_the_first_name_has_been_updated
    expect(page).to have_css('.govuk-summary-list__row', text: 'First name Jack')
  end

  def when_i_commit_the_changes
    dsi_api_response(success: true)
    click_link_or_button 'Add user'
  end

  def then_i_see_a_success_message
    expect(page).to have_content('User added')
  end

  def and_the_new_user_appears_in_the_user_list
    expect(page).to have_content('Jack Smithinson - john.smith@example.com')
  end

  def and_the_new_user_gets_an_invitation_email
    open_email('john.smith@example.com')
    expect(current_email.subject).to have_content I18n.t('provider_mailer.permissions_granted.subject',
                                                         permissions_granted_by_user: @provider_user.full_name,
                                                         organisation: @provider.name)
  end
end
