require 'rails_helper'

RSpec.describe 'A candidate filling in their personal details' do
  VALID_PERSONAL_DETAILS = {
    first_name: 'John',
    last_name: 'Doe',
    title: 'Dr',
    preferred_name: 'Dr Doe',
    nationality: 'British',
    date_of_birth: Date.new(1997, 3, 13)
  }.freeze

  it 'can enter details into the form, and see them on the finished application' do
    visit '/'
    click_on t('application_form.begin_button')

    expect(page).to have_content t('application_form.personal_details_section.heading')

    fill_in_personal_details(VALID_PERSONAL_DETAILS)

    click_on t('application_form.save_and_continue')

    expect(page).to have_content t('application_form.check_your_answers')
    expect(page).to have_content t('application_form.personal_details_section.heading')

    within '.govuk-summary-list' do
      expect_description_list_item(
        t('application_form.personal_details_section.title.label'),
        VALID_PERSONAL_DETAILS[:title]
      )
      expect_description_list_item(
        t('application_form.personal_details_section.first_name.label'),
        VALID_PERSONAL_DETAILS[:first_name]
      )
      expect_description_list_item(
        t('application_form.personal_details_section.last_name.label'),
        VALID_PERSONAL_DETAILS[:last_name]
      )
      expect_description_list_item(
        t('application_form.personal_details_section.preferred_name.label'),
        VALID_PERSONAL_DETAILS[:preferred_name]
      )
      expect_description_list_item(
        t('application_form.personal_details_section.nationality.label'),
        VALID_PERSONAL_DETAILS[:nationality]
      )
    end

    click_on t('application_form.submit')

    expect(page).to have_content t('application_form.application_submitted')
  end

  def fill_in_personal_details(details)
    fill_in t('application_form.personal_details_section.title.label'), with: details[:title]
    fill_in t('application_form.personal_details_section.first_name.label'), with: details[:first_name]
    fill_in t('application_form.personal_details_section.preferred_name.label'), with: details[:preferred_name]
    fill_in t('application_form.personal_details_section.last_name.label'), with: details[:last_name]

    within '.govuk-date-input' do
      fill_in 'Day', with: details[:date_of_birth].day
      fill_in 'Month', with: details[:date_of_birth].month
      fill_in 'Year', with: details[:date_of_birth].year
    end

    fill_in t('application_form.personal_details_section.nationality.label'), with: details[:nationality]
  end

  # search for a <dt> with an expected name adjacent to a <dd> with an expected value
  def expect_description_list_item(key, value)
    expect(find('dt', text: key).find('+dd')).to have_content(value)
  end
end
