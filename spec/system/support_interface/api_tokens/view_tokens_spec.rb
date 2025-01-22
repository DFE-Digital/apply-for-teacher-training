require 'rails_helper'

RSpec.describe 'API tokens' do
  include DfESignInHelpers

  scenario 'Support views vendors with api tokens' do
    given_i_am_signed_in
    and_api_tokens_exist
    when_i_visit_the_tokens_page
    then_i_see_all_the_providers_with_api_tokens
  end

  def given_i_am_signed_in
    sign_in_as_support_user
  end

  def and_api_tokens_exist
    vendor = create(:vendor, name: 'vendor_1')
    provider_1 = create(:provider, name: 'Provider 1', vendor:)
    provider_2 = create(:provider, name: 'Provider 2', vendor:)

    create(:vendor_api_token, provider: provider_1, last_used_at: 1.month.ago)
    create(:vendor_api_token, provider: provider_2)
  end

  def when_i_visit_the_tokens_page
    visit support_interface_api_tokens_path
  end

  def then_i_see_all_the_providers_with_api_tokens
    expect(page).to have_content '2 API tokens issued'
    expect(page).to have_content '1 API tokens used in the last 3 months'

    within '.govuk-table' do
      expect(page).to have_content 'Provider 1'
      expect(page).to have_content 'Provider 2'
      expect(page).to have_content 'vendor_1'
    end
  end
end
