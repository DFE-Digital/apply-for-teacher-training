require 'rails_helper'

RSpec.feature 'Active provider users CSV' do
  include DfESignInHelpers

  scenario 'support user can download a CSV with all the provider users who have signed in' do
    given_i_am_a_support_user
    and_there_are_active_provider_users

    when_i_visit_the_provider_users_page
    and_i_click_on_download_active_provider_users
    then_i_should_be_able_to_download_a_csv
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_active_provider_users
    create_list(:provider_user, 3, last_signed_in_at: 1.day.ago)
  end

  def when_i_visit_the_provider_users_page
    visit support_interface_provider_users_path
  end

  def and_i_click_on_download_active_provider_users
    click_link 'Download active provider users (CSV)'
  end

  def then_i_should_be_able_to_download_a_csv
    expect(page).to have_content ProviderUser.first.full_name
    expect(page).to have_content ProviderUser.second.full_name
    expect(page).to have_content ProviderUser.third.full_name
  end
end
