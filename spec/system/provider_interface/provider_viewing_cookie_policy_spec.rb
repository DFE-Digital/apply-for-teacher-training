require 'rails_helper'

RSpec.feature 'Viewing cookie policy' do
  scenario 'Provider views the cookie policy' do
    given_i_am_on_the_provider_interface
    when_i_can_click_on_cookie_policy
    then_i_can_see_the_cookie_policy
  end

  def given_i_am_on_the_provider_interface
    visit provider_interface_path
  end

  def when_i_can_click_on_cookie_policy
    within('.govuk-footer') { click_link t('layout.cookie_policy') }
  end

  def then_i_can_see_the_cookie_policy
    expect(page).to have_content(t('page_titles.cookies_provider'))
  end
end
