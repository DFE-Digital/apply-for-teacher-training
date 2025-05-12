require 'rails_helper'

RSpec.describe 'API tokens' do
  include DfESignInHelpers

  scenario 'Support views vendors with api tokens' do
    given_i_am_signed_in
    and_api_tokens_exist
    when_i_visit_the_tokens_page
    then_i_see_the_count_of_providers_with_api_tokens

    when_i_filter_by_a_vendor
    then_i_see_only_the_providers_for_a_specific_vendor

    when_i_filter_by_a_vendor

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

    create(:vendor_api_token, provider: provider_1, last_used_at: 1.month.ago)
    create(:vendor_api_token, provider: provider_2)
    create_list(:vendor_api_token, 20)
  end

  def when_i_visit_the_tokens_page
    visit support_interface_api_tokens_path
  end

  def then_i_see_the_count_of_providers_with_api_tokens
    expect(page).to have_content '22 API tokens issued'
    expect(page).to have_content '1 API tokens used in the last 3 months'

    within '.govuk-table' do
      expect(page).to have_content 'Provider 1'
      expect(page).to have_content 'Provider 2'
      expect(page).to have_content 'vendor_1'
      expect(page).to have_content 'vendor_2'
    end
  end

  def when_i_filter_by_a_vendor
    within('.moj-filter__options') do
      check('vendor_1')
    end

    click_link_or_button 'Apply filters'
  end

  def then_i_see_only_the_providers_for_a_specific_vendor
    expect(page).to have_content '1 API tokens issued'
    expect(page).to have_content '1 API tokens used in the last 3 months'

    within '.govuk-table' do
      expect(page).to have_content 'Provider 1'
      expect(page).to have_content 'vendor_1'
    end
  end

  def when_i_click_download_csv
    click_link_or_button 'Download CSV'
  end

  def then_i_receive_a_csv_file
    expect(response_headers['Content-Type']).to eq 'text/csv'
  end
end
