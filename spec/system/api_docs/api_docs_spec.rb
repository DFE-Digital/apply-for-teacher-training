require 'rails_helper'

RSpec.feature 'API docs' do
  scenario 'User browses through the API docs' do
    given_i_am_a_vendor
    i_can_browse_the_api_docs
  end

  def given_i_am_a_vendor
    # No authentication necessary
  end

  def i_can_browse_the_api_docs
    visit api_docs_home_path
    expect(page).to have_content 'This is API documentation'

    click_link 'Usage scenarios'
    expect(page).to have_content 'The scenarios on this page'

    click_link 'API reference'
    expect(page).to have_content 'Developing on the API'

    click_link 'Release notes'
    expect(page).to have_content 'For a log of pre-release changes, see the alpha release notes'

    click_link 'Get help'
    expect(page).to have_content 'If you have any questions or'
  end
end
