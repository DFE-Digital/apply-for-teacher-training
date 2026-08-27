require 'rails_helper'

RSpec.describe 'User permissions', :with_cache do
  include DfESignInHelpers

  scenario 'Provider user edits another user’s permissions' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_can_manage_users_for_one_provider
    and_i_sign_in_to_the_provider_interface

    when_i_go_to_organisation_settings
    and_i_view_users_for_my_provider
    and_i_click_on_a_user
    and_i_click_on_the_change_link
    then_i_see_a_permissions_form_page

    when_i_check_manage_api_tokens
    and_i_click_on_continue
    then_i_see_the_manage_api_token_interruption

    when_i_click_on_continue
    then_i_see_the_check_page
    and_i_see_only_manage_api_tokens_is_active

    when_i_click_on_change_manage_api_tokens
    and_i_check_manage_users
    and_i_click_on_continue
    then_i_see_the_manage_api_token_interruption

    when_i_click_on_continue
    then_i_see_the_check_page
    and_i_see_manage_users_and_manage_api_tokens_are_active

    when_i_click_on_change_manage_api_tokens
    and_i_check_all_permissions
    and_i_click_on_continue
    then_i_see_the_check_page
    and_i_see_all_permissions_are_active

    when_i_submit_the_modified_permissions
    then_i_see_the_user_page
  end

private

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_can_manage_users_for_one_provider
    @manage_users_provider = create(:provider, code: 'ABC')
    @provider_user = create(
      :provider_user,
      :with_manage_users,
      providers: [@manage_users_provider],
      dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
    )

    @manageable_user = create(
      :provider_user,
      providers: [@manage_users_provider],
    )
  end

  def when_i_go_to_organisation_settings
    click_link_or_button 'Organisation settings', match: :first
  end

  def and_i_view_users_for_my_provider
    click_link_or_button "Users #{@manage_users_provider.name}"
  end

  def and_i_click_on_a_user
    click_link_or_button @manageable_user.full_name
  end

  def and_i_click_on_the_change_link
    click_link_or_button 'Change Manage users'
  end

  def then_i_see_a_permissions_form_page
    expect(page).to have_text("#{@manageable_user.full_name} - #{@manage_users_provider.name}")
    expect(page).to have_text('User permissions')
    expect(page).to have_field('Manage users', checked: false)
    expect(page).to have_field('Manage organisation permissions', checked: false)
    expect(page).to have_field('Manage interviews', checked: false)
    expect(page).to have_field('Send offers, invitations and rejections', checked: false)
    expect(page).to have_field('View criminal convictions and professional misconduct', checked: false)
    expect(page).to have_field('View sex, disability and ethnicity information', checked: false)
    expect(page).to have_field('Manage API tokens', checked: false)
  end

  def when_i_check_manage_api_tokens
    check 'Manage API tokens'
  end

  def and_i_click_on_continue
    click_on 'Continue'
  end
  alias_method :when_i_click_on_continue, :and_i_click_on_continue

  def then_i_see_the_manage_api_token_interruption
    expect(page).to have_current_path(
      manage_api_token_interruption_provider_interface_organisation_settings_organisation_user_permissions_path(
        @manage_users_provider,
        @manageable_user,
      ),
    )
    expect(page).to have_element(:h1, text: 'This will give the user access to all your organisation’s data in the API')
    expect(page).to have_element(:p, text: 'You are giving this user permission to manage API tokens.')
    expect(page).to have_element(
      :p,
      text: 'They will not be able to view or manage anything you have not selected in this service. ' \
            'However, anyone who can manage API tokens can use the API to access all data in your organisation.',
    )
  end

  def then_i_see_the_check_page
    expect(page).to have_current_path(
      check_provider_interface_organisation_settings_organisation_user_permissions_path(
        @manage_users_provider,
        @manageable_user,
      ),
    )
    expect(page).to have_text('Check and save user permissions')
  end

  def and_i_see_only_manage_api_tokens_is_active
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage users No')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage organisation permissions No')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage interviews No')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Send offers, invitations and rejections No')
    expect(page).to have_css('.govuk-summary-list__row', text: 'View criminal convictions and professional misconduct No')
    expect(page).to have_css('.govuk-summary-list__row', text: 'View sex, disability and ethnicity information No')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage API tokens Yes')
  end

  def when_i_click_on_change_manage_api_tokens
    click_on 'Change Manage API tokens'
  end

  def and_i_check_manage_users
    check 'Manage users'
  end

  def and_i_see_manage_users_and_manage_api_tokens_are_active
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage users Yes')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage organisation permissions No')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage interviews No')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Send offers, invitations and rejections No')
    expect(page).to have_css('.govuk-summary-list__row', text: 'View criminal convictions and professional misconduct No')
    expect(page).to have_css('.govuk-summary-list__row', text: 'View sex, disability and ethnicity information No')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage API tokens Yes')
  end

  def and_i_check_all_permissions
    check 'Manage users'
    check 'Manage organisation permissions'
    check 'Manage interviews'
    check 'Send offers, invitations and rejections'
    check 'View criminal convictions and professional misconduct'
    check 'View sex, disability and ethnicity information'
    check 'Manage API tokens'
  end

  def and_i_see_all_permissions_are_active
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage users Yes')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage organisation permissions Yes')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage interviews Yes')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Send offers, invitations and rejections Yes')
    expect(page).to have_css('.govuk-summary-list__row', text: 'View criminal convictions and professional misconduct Yes')
    expect(page).to have_css('.govuk-summary-list__row', text: 'View sex, disability and ethnicity information Yes')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage API tokens Yes')
  end

  def when_i_submit_the_modified_permissions
    click_link_or_button 'Save user permissions'
  end

  def then_i_see_the_user_page
    expect(page).to have_text('User permissions updated')
    expect(page).to have_css('h1', text: @manageable_user.full_name)
  end
end
