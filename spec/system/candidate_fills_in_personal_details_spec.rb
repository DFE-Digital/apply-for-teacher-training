require 'rails_helper'

RSpec.describe 'A candidate filling in their personal details' do
  it 'can enter details into the form, and see them on the finished application' do
    visit '/'
    click_on t('application_form.begin_button')

    expect(page).to have_content t('application_form.personal_details_section.heading')

    fill_in 'Title', with: 'Dr'
    fill_in t('application_form.personal_details_section.first_name.label'), with: 'John'
    fill_in t('application_form.personal_details_section.preferred_name.label'), with: 'Dr Doe'
    fill_in t('application_form.personal_details_section.last_name.label'), with: 'Doe'

    click_on t('application_form.save_and_continue')

    expect(page).to have_content t('application_form.personal_details_section.heading')
    expect(page).to have_content t('application_form.review_answers')

    expect(page).to have_content('Title')
    expect(page).to have_content('Dr')
    expect(page).to have_content('First name')
    expect(page).to have_content('John')
    expect(page).to have_content('Last name')
    expect(page).to have_content('Doe')
    expect(page).to have_content('Name you prefer to be addressed by')
    expect(page).to have_content('Doe')

    click_on t('application_form.submit')

    expect(page).to have_content t('application_form.application_complete')

    expect(page).to have_content('Title')
    expect(page).to have_content('Dr')
    expect(page).to have_content('First name')
    expect(page).to have_content('John')
    expect(page).to have_content('Last name')
    expect(page).to have_content('Doe')
    expect(page).to have_content('Name you prefer to be addressed by')
    expect(page).to have_content('Dr Doe')
  end
end
