require 'rails_helper'

RSpec.describe 'Candidate content' do
  include ActionView::Helpers::DateHelper

  scenario 'Candidate views the content pages' do
    given_i_am_on_the_start_page
    and_the_one_login_candidate_feature_flag_is_enabled
    when_i_click_on_accessibility
    then_i_can_see_the_accessibility_statement
    and_i_can_see_the_cookie_banner

    when_i_click_on_the_cookies_page
    then_i_can_see_the_cookies_page
    and_i_can_no_longer_see_the_cookie_banner
    and_i_can_opt_in_to_tracking_website_usage

    when_i_click_on_complaints
    then_i_can_see_the_complaints_page

    when_i_click_on_the_terms_of_use
    then_i_can_see_the_terms_candidate

    when_click_on_guidance_for_using_ai
    then_i_can_see_the_ai_guidance

    when_i_click_on_the_privacy_policy
    then_i_can_see_the_privacy_policy
  end

  def and_the_one_login_candidate_feature_flag_is_enabled
    FeatureFlag.activate(:one_login_candidate_sign_in)
  end

  def when_click_on_guidance_for_using_ai
    within('.govuk-footer') { click_link_or_button t('layout.support_links.guidance_for_using_ai') }
  end

  def then_i_can_see_the_ai_guidance
    expect(page).to have_content(t('page_titles.guidance_for_using_ai'))
  end

  def given_i_am_on_the_start_page
    visit '/'
  end

  def when_i_click_on_accessibility
    within('.govuk-footer') { click_link_or_button t('layout.support_links.accessibility') }
  end

  def then_i_can_see_the_accessibility_statement
    expect(page).to have_content(t('page_titles.accessibility'))
  end

  def and_i_can_see_the_cookie_banner
    expect(page).to have_content('Cookies on Apply for teacher training')
  end

  def when_i_click_on_the_cookies_page
    within('.govuk-footer') { click_link_or_button t('layout.support_links.cookies') }
  end

  def and_i_can_no_longer_see_the_cookie_banner
    expect(page).to have_no_content('We use cookies to collect information about how you use Apply for teacher training')
  end

  def then_i_can_see_the_cookies_page
    expect(page).to have_content(t('page_titles.cookies_candidate'))
    expect(page).to have_content('When you close your browser')
  end

  def and_i_can_opt_in_to_tracking_website_usage
    choose 'Yes'
    click_link_or_button 'Save cookie settings'
    expect(page).to have_content('Your cookie preferences have been updated')
  end

  def when_i_click_on_complaints
    within('.govuk-footer') { click_link_or_button t('layout.support_links.candidate_complaints') }
  end

  def then_i_can_see_the_complaints_page
    expect(page).to have_css('h1', text: t('page_titles.candidate_complaints'))
  end

  def when_i_click_on_the_privacy_policy
    within('.govuk-footer') { click_link_or_button t('layout.support_links.privacy_policy') }
  end

  def then_i_can_see_the_privacy_policy
    expect(current_url).to eq t('personal_information_charter.url')
  end

  def when_i_click_on_the_terms_of_use
    within('.govuk-footer') { click_link_or_button t('layout.support_links.terms_of_use') }
  end

  def then_i_can_see_the_terms_candidate
    expect(page).to have_content(t('page_titles.terms_candidate'))
  end
end
