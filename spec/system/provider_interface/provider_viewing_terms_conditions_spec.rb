require 'rails_helper'

RSpec.feature 'Viewing terms and conditions' do
  scenario 'Provider views the terms and conditions' do
    given_i_am_on_the_provider_interface
    when_i_can_click_on_terms_of_use
    then_i_can_see_the_terms_candidate
  end

  def given_i_am_on_the_provider_interface
    visit provider_interface_path
  end

  def when_i_can_click_on_terms_of_use
    within('.govuk-footer') { click_link t('layout.terms_of_use') }
  end

  def then_i_can_see_the_terms_candidate
    expect(page).to have_content(t('page_titles.terms_provider'))
  end
end
