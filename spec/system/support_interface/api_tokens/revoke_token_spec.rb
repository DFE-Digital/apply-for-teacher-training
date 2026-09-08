require 'rails_helper'

RSpec.describe 'API tokens' do
  include DfESignInHelpers

  scenario 'Support revokes a token' do
    given_i_am_signed_in
    and_providers_exist_with_api_tokens
    when_i_visit_a_token
    and_i_click_revoke
    and_i_confirm_revocation
    then_that_provider_no_longer_has_an_api_token
    but_the_other_provider_still_has_an_api_token
  end

  def given_i_am_signed_in
    sign_in_as_support_user
  end

  def and_providers_exist_with_api_tokens
    @provider_1 = create(:provider, name: 'Provider 1')
    @provider_2 = create(:provider, name: 'Provider 2')

    create(:vendor_api_token, provider: @provider_1, description: 'Token for Provider 1')
    create(:vendor_api_token, provider: @provider_2, description: 'Token for Provider 2')
  end

  def when_i_visit_a_token
    visit support_interface_api_tokens_path
    click_link_or_button 'Token for Provider 1'
  end

  def and_i_click_revoke
    click_link_or_button 'Revoke token'
  end

  def and_i_confirm_revocation
    expect(page).to have_text('Are you sure you want to revoke Token for Provider 1?')

    fill_in 'Audit log comment', with: 'https://becomingateacher.zendesk.com/agent/tickets/123'

    click_link_or_button 'Yes, revoke this API token'
  end

  def then_that_provider_no_longer_has_an_api_token
    expect(page).to have_text('You have revoked Token for Provider 1')

    within '.govuk-table' do
      expect(page).to have_no_text('Provider 1')
    end
  end

  def but_the_other_provider_still_has_an_api_token
    within '.govuk-table' do
      expect(page).to have_text('Provider 2')
    end
  end
end
