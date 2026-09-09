require 'rails_helper'

RSpec.describe 'API tokens' do
  include DfESignInHelpers

  scenario 'Support views vendors with api tokens' do
    given_i_am_signed_in
    and_api_tokens_exist
    when_i_visit_the_tokens_page
    then_i_see_the_api_tokens

    when_i_filter_by_a_vendor
    then_i_see_only_the_tokens_for_a_specific_vendor

    when_i_click_download_csv
    then_i_receive_a_csv_file
  end

  def given_i_am_signed_in
    sign_in_as_support_user
  end

  def and_api_tokens_exist
    vendor_1 = create(:vendor, name: 'vendor_1')
    vendor_2 = create(:vendor, name: 'vendor_2')
    provider_1 = create(:provider, name: 'Provider 1', vendor: vendor_1)
    provider_2 = create(:provider, name: 'Provider 2', vendor: vendor_2)

    create(:vendor_api_token, provider: provider_1, description: 'Token for Provider 1', last_used_at: 1.month.ago)
    create(:vendor_api_token, provider: provider_2, description: 'Token for Provider 2')
  end

  def when_i_visit_the_tokens_page
    visit support_interface_api_tokens_path
  end

  def then_i_see_the_api_tokens
    within '.govuk-table' do
      expect(page).to have_text 'Provider 1'
      expect(page).to have_text 'Token for Provider 1'
      expect(page).to have_text 'Provider 2'
      expect(page).to have_text 'Token for Provider 2'
    end
  end

  def when_i_filter_by_a_vendor
    within('.moj-filter__options') do
      check('Vendor 1')
    end

    click_link_or_button 'Apply filters'
  end

  def then_i_see_only_the_tokens_for_a_specific_vendor
    within '.govuk-table' do
      expect(page).to have_text 'Provider 1'
      expect(page).to have_text 'Token for Provider 1'
      expect(page).to have_no_text 'Provider 2'
      expect(page).to have_no_text 'Token for Provider 2'
    end
  end

  def when_i_click_download_csv
    click_link_or_button 'Download CSV'
  end

  def then_i_receive_a_csv_file
    expect(response_headers['Content-Type']).to eq 'text/csv'
  end
end
