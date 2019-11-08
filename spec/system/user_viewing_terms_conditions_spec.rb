require 'rails_helper'

RSpec.feature 'Viewing terms and conditions' do
  scenario 'User views the terms and conditions' do
    given_i_am_on_the_start_page
    when_i_can_click_on_terms_conditions
    then_i_can_see_the_terms_conditions
  end

  def given_i_am_on_the_start_page
    visit '/'
  end

  def when_i_can_click_on_terms_conditions
    within('.govuk-footer') { click_link t('layout.terms_conditions') }
  end

  def then_i_can_see_the_terms_conditions
    expect(page).to have_content(t('page_titles.terms_conditions'))
  end
end
