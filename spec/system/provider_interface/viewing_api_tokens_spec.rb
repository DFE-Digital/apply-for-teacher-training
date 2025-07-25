require 'rails_helper'

RSpec.describe 'Organisation users', :with_audited do
  include DfESignInHelpers
  include Rails.application.routes.url_helpers

  before { FeatureFlag.activate(:api_token_management) }

  scenario 'viewing and adding api tokens' do
    given_i_am_a_provider_user_signed_in_with_permissions_to_manage_tokens

    when_i_navigate_to_the_api_tokens_page
    then_i_see_the_no_tokens_message
    and_link_to_api_docs

    when_i_click_on('Add token')
    then_i_see_the_create_token_page

    when_i_click_on('Back')
    then_i_see_the_no_tokens_message

    when_i_click_on('Add token')
    and_i_click_on('Continue')

    then_i_see_the_token
    when_i_click_on('Back')
    then_i_see_my_new_token_in_the_list

    given_the_token_has_been_used
    when_i_refresh_the_page
    then_i_see_the_token_in_the_list_with_last_used_date
  end

  scenario 'viewing list only' do
    given_i_am_a_provider_user_signed_in_without_permissions_to_manage_tokens
    and_a_token_exists_that_has_been_used

    when_i_navigate_to_the_api_tokens_page
    then_i_see_the_token_created_by_support_user_in_the_list_with_last_used_date
    and_i_do_not_see_the_add_button
  end

private

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

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

  def and_a_token_exists_that_has_been_used
    create(:vendor_api_token, :with_last_used_at, provider: @provider)
  end

  def when_i_navigate_to_the_api_tokens_page
    visit provider_interface_path
    click_on 'Organisation settings'
    click_on 'API tokens'
  end

  def then_i_see_the_no_tokens_message
    expect(page).to have_content 'There are no API tokens for this organisation'
  end

  def then_i_see_my_new_token_in_the_list
    token = VendorAPIToken.last
    within('.govuk-table') do
      expect(page).to have_content 'Never'
      expect(page).to have_content token.created_at.to_fs(:govuk_date_and_time)
      expect(page).to have_content @provider_user.email_address
    end
  end

  def then_i_see_the_token_in_the_list_with_last_used_date
    token = VendorAPIToken.last
    within('.govuk-table') do
      expect(page).to have_content token.last_used_at.to_fs(:govuk_date_and_time)
      expect(page).to have_content token.created_at.to_fs(:govuk_date_and_time)
      expect(page).to have_content @provider_user.email_address
    end
  end

  def then_i_see_the_token_created_by_support_user_in_the_list_with_last_used_date
    token = VendorAPIToken.last
    within('.govuk-table') do
      expect(page).to have_content token.last_used_at.to_fs(:govuk_date_and_time)
      expect(page).to have_content token.created_at.to_fs(:govuk_date_and_time)
      expect(page).to have_content 'DFE support user'
    end
  end

  def and_i_do_not_see_the_add_button
    expect(page).to have_no_button 'Add token'
  end

  def then_i_see_success_message
    expect(page).to have_content 'API token deleted'
  end

  def given_the_token_has_been_used
    token = VendorAPIToken.last
    token.update(last_used_at: 2.days.ago)
  end

  def when_i_refresh_the_page
    url = page.current_url
    visit url
  end

  def then_i_see_the_warning_page
    token = VendorAPIToken.last
    expect(page).to have_content 'Are you sure you want to revoke this token?'
    expect(page).to have_content "The token was last used on #{token.last_used_at.to_fs(:govuk_date_and_time)}"
    expect(page).to have_content 'If you delete, any integrations that are still using this token will fail. Only delete if you are confident it is no longer in use.'
  end

  def and_link_to_api_docs
    expect(page).to have_link('Apply API (test)', href: api_docs_home_path)
  end

  def then_i_see_the_create_token_page
    expect(page).to have_content "Clicking continue will create a token for #{@provider.name}. It will be visible until you navigate away from the page."
  end

  def then_i_see_the_token
    expect(page).to have_text('New API token generated')
  end
end
