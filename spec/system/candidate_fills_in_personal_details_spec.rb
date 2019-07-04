require 'rails_helper'

RSpec.describe 'A candidate filling in their personal details' do
  it 'can enter details into the form, and see them on the finished application' do
    visit '/'
    click_on t('application_form.begin_button')

    expect(page).to have_content t('application_form.personal_details_section.heading')

    fill_in 'Title', with: 'Dr'

    click_on t('application_form.save_and_continue')

    expect(page).to have_content t('application_form.personal_details_section.heading')
    expect(page).to have_content t('application_form.review_answers')

    expect(page).to have_content('Title')
    expect(page).to have_content('Dr')

    click_on t('application_form.submit')

    expect(page).to have_content t('application_form.application_complete')
    expect(page).to have_content 'Dr'
  end
end
