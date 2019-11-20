require 'rails_helper'

RSpec.feature 'Viewing cookie policy' do
  scenario 'Candidate views the cookie policy' do
    given_i_am_on_the_start_page
    when_i_can_click_on_cookie_policy
    then_i_can_see_the_cookie_policy
  end

  def given_i_am_on_the_start_page
    visit '/'
  end

  def when_i_can_click_on_cookie_policy
    within('.govuk-footer') { click_link t('layout.cookie_policy') }
  end

  def then_i_can_see_the_cookie_policy
    expect(page).to have_content(t('page_titles.cookies_candidate'))
  end
end
