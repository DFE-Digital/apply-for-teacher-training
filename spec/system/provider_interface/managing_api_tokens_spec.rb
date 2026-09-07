require 'rails_helper'

RSpec.describe 'Organisation users', :with_audited do
  include DfESignInHelpers
  include Rails.application.routes.url_helpers

  scenario 'creating an in-house api token' do
    given_i_am_a_provider_user_signed_in_with_permissions_to_manage_tokens
    given_the_in_house_vendor_exists

    when_i_navigate_to_the_api_tokens_page
    then_i_see_the_no_tokens_message
    and_i_see_a_link_to_api_docs

    when_i_click_on('Create a token')
    then_i_see_the_create_token_page

    when_i_click_on('Back')
    then_i_see_the_no_tokens_message

    when_i_click_on('Create a token')
    and_i_click_on('Create token')
    then_i_see_errors_for_description_and_vendor_type

    when_i_add_a_description_and_select_in_house
    and_i_click_on('Create token')
    then_i_see_the_success_page

    when_i_click_on('Back')
    then_i_see_my_new_token_in_the_active_list

    and_i_click_on_the_token_description
    then_i_see_the_in_house_token_show_page
    and_i_see_the_revoke_link
  end

  scenario 'revoking an api token' do
    given_i_am_a_provider_user_signed_in_with_permissions_to_manage_tokens
    given_i_have_created_an_in_house_token

    when_i_navigate_to_the_api_tokens_page
    and_i_click_on_the_token_description
    then_i_see_the_in_house_token_show_page

    when_i_click_on('Revoke')
    then_i_see_the_confirm_revoke_page

    when_i_click_on('Yes, revoke this API token')
    then_i_see_the_revoked_flash_message

    when_i_click_on('Revoked tokens')
    then_i_see_the_token_in_the_list_with_description @token_description

    and_i_click_on_the_token_description
    then_i_see_the_revoked_token_show_page
  end

  scenario 'viewing a third-party api token' do
    given_i_am_a_provider_user_signed_in_with_permissions_to_manage_tokens
    given_i_have_created_a_third_party_token

    when_i_navigate_to_the_api_tokens_page
    and_i_click_on_the_token_description
    then_i_see_the_third_party_token_show_page
  end

  scenario 'viewing list only without manage permissions' do
    given_i_am_a_provider_user_signed_in_without_permissions_to_manage_tokens
    and_a_token_exists_that_has_been_used

    when_i_navigate_to_the_api_tokens_page
    then_i_see_the_token_created_by_support_user_in_the_list
    and_i_do_not_see_the_create_button
  end

  scenario 'tab navigation between active and revoked tokens' do
    given_i_am_a_provider_user_signed_in_with_permissions_to_manage_tokens
    given_i_have_an_active_token_and_a_revoked_token

    when_i_navigate_to_the_api_tokens_page
    then_i_see_the_active_tab_is_current
    and_i_see_the_token_in_the_list_with_description @active_token_description
    and_i_do_not_see_the_token_in_the_list_with_description @revoked_token_description

    when_i_click_on('Revoked tokens')
    then_i_see_the_revoked_tab_is_current
    and_i_see_the_token_in_the_list_with_description @revoked_token_description
    and_i_do_not_see_the_token_in_the_list_with_description @active_token_description
  end

private

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def and_i_click_on_the_token_description
    within('.govuk-table') do
      click_link @token_description
    end
  end

  def given_i_am_a_provider_user_signed_in_with_permissions_to_manage_tokens
    @provider = build(:provider)
    @provider_user = create(
      :provider_user,
      :with_manage_api_tokens,
      dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
      email_address: 'email@provider.ac.uk',
      providers: [@provider],
    )
    user_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
  end

  def given_i_am_a_provider_user_signed_in_without_permissions_to_manage_tokens
    @provider = build(:provider)
    @provider_user = create(
      :provider_user,
      dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
      email_address: 'email@provider.ac.uk',
      providers: [@provider],
    )
    user_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
  end

  def given_the_in_house_vendor_exists
    create(:vendor)
  end

  def given_i_have_created_an_in_house_token
    @token_description = 'Token for vendor integration test'
    in_house_vendor = create(:vendor)
    Audited.audit_class.as_user(@provider_user) do
      @api_token = create(
        :vendor_api_token,
        provider: @provider,
        description: @token_description,
        vendor: in_house_vendor,
      )
    end
  end

  def given_i_have_created_a_third_party_token
    @vendor = create(:vendor, name: 'Tribal', status: :confirmed)
    @token_description = 'Integration with Tribal'
    Audited.audit_class.as_user(@provider_user) do
      @api_token = create(
        :vendor_api_token,
        provider: @provider,
        description: @token_description,
        vendor: @vendor,
      )
    end
  end

  def given_i_have_an_active_token_and_a_revoked_token
    @active_token_description = 'Active token'
    @revoked_token_description = 'Revoked token'
    in_house_vendor = create(:vendor)
    Audited.audit_class.as_user(@provider_user) do
      @active_token = create(
        :vendor_api_token,
        provider: @provider,
        description: @active_token_description,
        vendor: in_house_vendor,
      )
      @revoked_token = create(
        :vendor_api_token,
        provider: @provider,
        description: @revoked_token_description,
        vendor: in_house_vendor,
      )
    end
    @revoked_token.discard
  end

  def and_a_token_exists_that_has_been_used
    create(:vendor_api_token, :with_last_used_at, provider: @provider)
  end

  def when_i_navigate_to_the_api_tokens_page
    visit provider_interface_path
    click_on 'Organisation settings'
    click_on 'API tokens'
  end

  def when_i_add_a_description_and_select_in_house
    @token_description = 'Token for vendor integration test'
    fill_in 'Name', with: @token_description
    choose 'In-house developers'
  end

  def then_i_see_the_no_tokens_message
    expect(page).to have_text 'There are no API tokens for this organisation'
  end

  def and_i_see_a_link_to_api_docs
    expect(page).to have_link('View the test API documentation', href: api_docs_home_path)
  end

  def then_i_see_the_create_token_page
    expect(page).to have_text 'Create an API token'
    expect(page).to have_text 'Name'
    expect(page).to have_text 'Who is this token for?'
    expect(page).to have_text 'In-house developers'
    expect(page).to have_text 'A third-party software vendor'
    expect(page).to have_button 'Create token'
  end

  def then_i_see_errors_for_description_and_vendor_type
    expect(page.title).to include 'Error:'
    expect(page).to have_text 'There is a problem'
    expect(page).to have_text 'Enter a name'
    expect(page).to have_text 'Select who the token is for'
  end

  def then_i_see_the_success_page
    expect(page).to have_text 'Token created'
    expect(page).to have_css('code')
    expect(page).to have_text 'You cannot view this again'
    expect(page).to have_text 'Treat this token like a password'
  end

  def then_i_see_my_new_token_in_the_active_list
    expect(page).to have_text 'Active tokens'
    within('.govuk-table') do
      expect(page).to have_text 'Token for vendor integration test'
      expect(page).to have_text @provider_user.full_name
      expect(page).to have_text 'Never'
    end
  end

  def then_i_see_the_token_in_the_list_with_description(description)
    within('.govuk-table') do
      expect(page).to have_text description
    end
  end

  alias_method :and_i_see_the_token_in_the_list_with_description,
               :then_i_see_the_token_in_the_list_with_description

  def and_i_do_not_see_the_token_in_the_list_with_description(description)
    within('.govuk-table') do
      expect(page).to have_no_text description
    end
  end

  def then_i_see_the_token_created_by_support_user_in_the_list
    token = VendorAPIToken.last
    within('.govuk-table') do
      expect(page).to have_text token.last_used_at.to_fs(:govuk_date_and_time)
      expect(page).to have_text token.created_at.to_fs(:govuk_date_and_time)
      expect(page).to have_text 'DFE support user'
      expect(page).to have_text 'API token'
    end
  end

  def and_i_do_not_see_the_create_button
    expect(page).to have_no_button 'Create a token'
  end

  def then_i_see_the_in_house_token_show_page
    expect(page).to have_text @token_description
    within('.govuk-summary-list') do
      expect(page).to have_text @provider_user.full_name
      expect(page).to have_text 'In-house developers'
      expect(page).to have_text 'Never'
      expect(page).to have_text 'Active'
    end
  end

  def and_i_see_the_revoke_link
    expect(page).to have_link 'Revoke'
  end

  def then_i_see_the_third_party_token_show_page
    expect(page).to have_text @token_description
    within('.govuk-summary-list') do
      expect(page).to have_text @provider_user.full_name
      expect(page).to have_text 'Tribal'
      expect(page).to have_text 'Never'
      expect(page).to have_text 'Active'
    end
  end

  def then_i_see_the_revoked_token_show_page
    expect(page).to have_text @token_description
    within('.govuk-summary-list') do
      expect(page).to have_text @provider_user.full_name
      expect(page).to have_text 'In-house developers'
      expect(page).to have_text 'Never'
      expect(page).to have_text 'Revoked'
      expect(page).to have_text 'Revoked on'
      expect(page).to have_text 'Revoked by'
    end
  end

  def then_i_see_the_confirm_revoke_page
    expect(page).to have_text "Are you sure you want to revoke #{@token_description}?"
    expect(page).to have_text 'If you revoke this token, any software integrations using it will stop working immediately.'
    expect(page).to have_button 'Yes, revoke this API token'
  end

  def then_i_see_the_revoked_flash_message
    expect(page).to have_text "You have revoked #{@token_description}"
  end

  def then_i_see_the_active_tab_is_current
    within('.app-tab-navigation') do
      active_link = find_link('Active tokens')
      revoked_link = find_link('Revoked tokens')
      expect(active_link[:'aria-current']).to eq 'page'
      expect(revoked_link).to have_no_css('[aria-current]')
    end
  end

  def then_i_see_the_revoked_tab_is_current
    within('.app-tab-navigation') do
      active_link = find_link('Active tokens')
      revoked_link = find_link('Revoked tokens')
      expect(revoked_link[:'aria-current']).to eq 'page'
      expect(active_link).to have_no_css('[aria-current]')
    end
  end
end
