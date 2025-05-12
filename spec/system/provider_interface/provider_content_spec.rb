require 'rails_helper'

RSpec.describe 'Provider content' do
  scenario 'Provider views the content pages' do
    given_i_am_on_the_provider_interface
    when_i_click_on_accessibility
    then_i_can_see_the_accessibility_statement

    and_i_can_see_the_cookie_banner

    when_i_click_on_the_cookies_page
    and_i_can_no_longer_see_the_cookie_banner
    then_i_can_see_the_cookies_page
    and_i_can_opt_in_to_tracking_website_usage

    when_i_click_on_the_service_guidance
    then_i_can_see_the_service_guidance_provider

    when_click_on_guidance_for_using_ai
    then_i_can_see_the_ai_guidance

    when_i_click_on_privacy
    then_i_see_the_privacy_notice_page
  end

  def when_click_on_guidance_for_using_ai
    within('.govuk-footer') { click_link_or_button t('layout.support_links.guidance_for_using_ai') }
  end

  def then_i_can_see_the_ai_guidance
    expect(page).to have_content(t('page_titles.guidance_for_using_ai'))
  end

  def given_i_am_on_the_provider_interface
    visit provider_interface_path
  end

  def when_i_click_on_accessibility
    within('.govuk-footer') { click_link_or_button t('layout.support_links.accessibility') }
  end

  def then_i_can_see_the_accessibility_statement
    expect(page).to have_content(t('page_titles.accessibility'))
  end

  def and_i_can_see_the_cookie_banner
    expect(page).to have_content('Cookies on Manage teacher training applications')
  end

  def when_i_click_on_the_cookies_page
    within('.govuk-footer') { click_link_or_button t('layout.support_links.cookies') }
  end

  def and_i_can_no_longer_see_the_cookie_banner
    expect(page).to have_no_content('We use cookies to collect information about how you use Manage teacher training applications')
  end

  def then_i_can_see_the_cookies_page
    expect(page).to have_content(t('page_titles.cookies_provider'))
  end

  def and_i_can_opt_in_to_tracking_website_usage
    choose 'Yes'
    click_link_or_button 'Save cookie settings'
    expect(page).to have_content('Your cookie preferences have been updated')
  end

  def when_i_click_on_privacy
    within('.govuk-footer') { click_link_or_button t('layout.support_links.privacy') }
  end

  def then_i_see_the_privacy_notice_page
    expect(current_url).to eq t('personal_information_charter.url')
  end

  def when_i_click_on_the_service_guidance
    within('.govuk-footer') { click_link_or_button t('layout.support.provider_service_guidance') }
  end

  def then_i_can_see_the_service_guidance_provider
    expect(page).to have_content(t('page_titles.service_guidance_provider'))
  end
end
