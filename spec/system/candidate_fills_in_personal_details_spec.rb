require 'rails_helper'

RSpec.describe 'A candidate filling in their personal details' do
  it 'can enter details into the form, and see them on the finished application' do
    visit '/'
    click_on t('application_form.begin_button')

    expect(page).to have_content t('application_form.personal_details_section.heading')

    fill_in t('application_form.personal_details_section.title.label'), with: 'Dr'
    fill_in t('application_form.personal_details_section.first_name.label'), with: 'John'
    fill_in t('application_form.personal_details_section.preferred_name.label'), with: 'Dr Doe'
    fill_in t('application_form.personal_details_section.last_name.label'), with: 'Doe'

    within '.govuk-date-input' do
      fill_in 'Day', with: 13
      fill_in 'Month', with: 3
      fill_in 'Year', with: 1997
    end

    click_on t('application_form.save_and_continue')

    expect(page).to have_content t('application_form.personal_details_section.heading')
    expect(page).to have_content t('application_form.review_answers')

    within '.govuk-summary-list' do
      expect_description_list_item(
        t('application_form.personal_details_section.title.label'),
        'Dr'
      )
      expect_description_list_item(
        t('application_form.personal_details_section.first_name.label'),
        'John'
      )
      expect_description_list_item(
        t('application_form.personal_details_section.last_name.label'),
        'Doe'
      )
      expect_description_list_item(
        t('application_form.personal_details_section.preferred_name.label'),
        'Dr Doe'
      )
      expect_description_list_item(
        t('application_form.personal_details_section.date_of_birth.label'),
        '13 March 1997'
      )
    end

    click_on t('application_form.submit')

    expect(page).to have_content t('application_form.application_complete')

    within '.govuk-summary-list' do
      expect_description_list_item(
        t('application_form.personal_details_section.title.label'),
        'Dr'
      )
      expect_description_list_item(
        t('application_form.personal_details_section.first_name.label'),
        'John'
      )
      expect_description_list_item(
        t('application_form.personal_details_section.last_name.label'),
        'Doe'
      )
      expect_description_list_item(
        t('application_form.personal_details_section.preferred_name.label'),
        'Dr Doe'
      )
      expect_description_list_item(
        t('application_form.personal_details_section.date_of_birth.label'),
        '13 March 1997'
      )
    end
  end

  # search for a <dt> with an expected name adjacent to a <dd> with an expected value
  def expect_description_list_item(key, value)
    expect(find('dt', text: key).find('+dd')).to have_content(value)
  end
end
