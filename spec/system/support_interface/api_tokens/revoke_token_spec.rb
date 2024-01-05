require 'rails_helper'

RSpec.feature 'API tokens' do
  include DfESignInHelpers

  scenario 'Support revokes a token' do
    given_i_am_signed_in
    and_providers_exist_with_api_tokens
    when_i_revoke_a_token_for_a_provider
    then_that_provider_should_no_longer_have_an_api_token
    but_the_other_provider_should_still_have_an_api_token
  end

  def given_i_am_signed_in
    sign_in_as_support_user
  end

  def and_providers_exist_with_api_tokens
    @provider_1 = create(:provider, :with_api_token, name: 'Provider 1')
    @provider_2 = create(:provider, :with_api_token, name: 'Provider 2')
  end

  def when_i_revoke_a_token_for_a_provider
    visit support_interface_api_tokens_path
    row = page.find('td', text: @provider_1.name).ancestor('tr')

    within row do
      click_link 'Revoke'
    end

    expect(page).to have_content('Confirm revocation')
    click_button 'Revoke'
  end

  def then_that_provider_should_no_longer_have_an_api_token
    within '.govuk-table' do
      expect(page).to have_no_content('Provider 1')
    end
  end

  def but_the_other_provider_should_still_have_an_api_token
    within '.govuk-table' do
      expect(page).to have_content('Provider 2')
    end
  end
end
