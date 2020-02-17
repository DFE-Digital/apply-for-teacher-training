require 'rails_helper'

RSpec.feature 'Candidate content' do
  include ActionView::Helpers::DateHelper

  scenario 'Candidate views the content pages' do
    given_i_am_on_the_start_page
    when_i_click_on_accessibility
    then_i_can_see_the_accessibility_statement

    when_i_click_on_the_cookie_policy
    then_i_can_see_the_cookie_policy

    when_i_click_on_the_privacy_policy
    then_i_can_see_the_privacy_policy

    when_i_click_on_the_terms_of_use
    then_i_can_see_the_terms_candidate
  end

  def given_i_am_on_the_start_page
    visit '/'
  end

  def when_i_click_on_accessibility
    within('.govuk-footer') { click_link t('layout.accessibility') }
  end

  def then_i_can_see_the_accessibility_statement
    expect(page).to have_content(t('page_titles.accessibility'))
  end

  def when_i_click_on_the_cookie_policy
    within('.govuk-footer') { click_link t('layout.cookie_policy') }
  end

  def then_i_can_see_the_cookie_policy
    expect(page).to have_content(t('page_titles.cookies_candidate'))
    expect(page).to have_content(distance_of_time_in_words(Devise.timeout_in))
  end

  def when_i_click_on_the_privacy_policy
    within('.govuk-footer') { click_link t('layout.privacy_policy') }
  end

  def then_i_can_see_the_privacy_policy
    expect(page).to have_content(t('page_titles.privacy_policy'))
  end

  def when_i_click_on_the_terms_of_use
    within('.govuk-footer') { click_link t('layout.terms_of_use') }
  end

  def then_i_can_see_the_terms_candidate
    expect(page).to have_content(t('page_titles.terms_candidate'))
  end
end
