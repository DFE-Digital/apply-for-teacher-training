require 'rails_helper'

RSpec.describe 'API docs' do
  scenario 'User browses through the API docs' do
    given_i_am_a_vendor
    i_can_browse_the_api_docs

    when_i_enter_an_incorrect_api_version_in_the_url
    then_i_get_redirected_to_the_latest_production_version
  end

  def given_i_am_a_vendor
    # No authentication necessary
  end

  def i_can_browse_the_api_docs
    visit api_docs_home_path
    expect(page).to have_content 'This is API documentation'

    click_link_or_button 'Usage scenarios'
    expect(page).to have_content 'The scenarios on this page'

    click_link_or_button 'API reference'
    expect(page).to have_content 'Developing on the API'
    expect(page).to have_content 'Field lengths summary'

    click_link_or_button 'Release notes'
    expect(page).to have_content 'For a log of pre-release changes, see the alpha release notes'

    click_link_or_button 'Get help'
    expect(page).to have_content 'If you have any questions or'

    click_link_or_button 'Lifecycle'
    expect(page).to have_content 'Application lifecycle'
  end

  def when_i_enter_an_incorrect_api_version_in_the_url
    visit api_docs_versioned_reference_path(api_version: 'v1.1.1')
  end

  def then_i_get_redirected_to_the_latest_production_version
    expect(page).to have_current_path api_docs_versioned_reference_path(api_version: "v#{VendorAPI::VERSION}"), ignore_query: true
  end
end
