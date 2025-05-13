require 'rails_helper'

RSpec.describe 'User permissions' do
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

    when_i_edit_the_permissions
    and_i_click_continue
    then_i_see_the_check_page

    when_i_click_change
    and_i_modify_the_selected_permissions
    and_i_click_continue
    then_i_see_the_check_page
    and_i_see_the_modified_permissions

    when_i_submit_the_modified_permissions
    then_i_see_the_user_page
    and_i_see_the_modified_permissions
  end

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
      :with_manage_users,
      :with_view_safeguarding_information,
      :with_make_decisions,
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
    expect(page).to have_content("#{@manageable_user.full_name} - #{@manage_users_provider.name}")
    expect(page).to have_content('User permissions')
    expect(page).to have_field('Manage users', checked: true)
    expect(page).to have_field('Manage organisation permissions', checked: false)
    expect(page).to have_field('Manage interviews', checked: false)
    expect(page).to have_field('Send offers, invitations and rejections', checked: true)
    expect(page).to have_field('View criminal convictions and professional misconduct', checked: true)
    expect(page).to have_field('View sex, disability and ethnicity information', checked: false)
  end

  def when_i_edit_the_permissions
    uncheck 'Manage users'
    check 'Manage interviews'
  end

  def and_i_click_continue
    click_link_or_button 'Continue'
  end

  def then_i_see_the_check_page
    expect(page).to have_content('Check and save user permissions')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage users No')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage organisation permissions No')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage interviews Yes')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Send offers, invitations and rejections Yes')
    expect(page).to have_css('.govuk-summary-list__row', text: 'View criminal convictions and professional misconduct Yes')
    expect(page).to have_css('.govuk-summary-list__row', text: 'View sex, disability and ethnicity information No')
  end

  def when_i_click_change
    click_link_or_button 'Change Manage users'
  end

  def and_i_modify_the_selected_permissions
    check 'Manage users'
    uncheck 'Manage interviews'
    check 'View sex, disability and ethnicity information'
  end

  def then_i_see_the_check_page
    expect(page).to have_content('Check and save user permissions')
  end

  def and_i_see_the_modified_permissions
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage users Yes')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage organisation permissions No')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Manage interviews No')
    expect(page).to have_css('.govuk-summary-list__row', text: 'Send offers, invitations and rejections Yes')
    expect(page).to have_css('.govuk-summary-list__row', text: 'View criminal convictions and professional misconduct Yes')
    expect(page).to have_css('.govuk-summary-list__row', text: 'View sex, disability and ethnicity information Yes')
  end

  def when_i_submit_the_modified_permissions
    click_link_or_button 'Save user permissions'
  end

  def then_i_see_the_user_page
    expect(page).to have_content('User permissions updated')
    expect(page).to have_css('h1', text: @manageable_user.full_name)
  end
end
