require 'rails_helper'

RSpec.feature 'Provider content' do
  scenario 'Provider views the content pages' do
    given_i_am_on_the_provider_interface
    when_i_click_on_accessibility
    then_i_can_see_the_accessibility_statement

    when_i_click_on_the_cookie_policy
    then_i_can_see_the_cookie_policy

    when_i_click_on_the_privacy_policy
    then_i_can_see_the_privacy_policy

    when_i_click_on_the_terms_of_use
    then_i_can_see_the_terms_provider
  end

  def given_i_am_on_the_provider_interface
    visit provider_interface_path
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
    expect(page).to have_content(t('page_titles.cookies_provider'))
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

  def then_i_can_see_the_terms_provider
    expect(page).to have_content(t('page_titles.terms_provider'))
  end
end
