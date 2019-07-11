require 'rails_helper'

describe 'A candidate leaves personal details blank' do
  it 'shows a summary with clickable links', js: true do
    visit '/'
    click_on t('application_form.begin_button')
    click_on t('application_form.save_and_continue')

    expect(page).to have_content('There is a problem')

    click_on 'Enter your first name'

    expect(page).to have_selector('#personal_details_first_name:focus')
  end
end
