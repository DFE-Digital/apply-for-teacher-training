require 'rails_helper'

RSpec.feature 'Viewing accessibility statement' do
  scenario 'Candidate views the accessibility statement' do
    given_i_am_on_the_start_page
    when_i_can_click_on_accessibility
    then_i_can_see_the_accessibility_statement
  end

  def given_i_am_on_the_start_page
    visit '/'
  end

  def when_i_can_click_on_accessibility
    within('.govuk-footer') { click_link t('layout.accessibility') }
  end

  def then_i_can_see_the_accessibility_statement
    expect(page).to have_content(t('page_titles.accessibility'))
  end
end
