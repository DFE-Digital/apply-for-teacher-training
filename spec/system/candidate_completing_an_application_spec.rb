require 'rails_helper'

describe 'A candidate completing an application for teacher training' do
  context 'who submits a valid application' do
    before do
      visit '/'
      click_on t('application_form.begin_button')

      fill_in_personal_details(
        first_name: 'John',
        last_name: 'Doe',
        title: 'Dr',
        preferred_name: 'Dr Doe',
        nationality: 'British',
        date_of_birth: Date.new(1997, 3, 13)
      )

      click_on t('application_form.save_and_continue')
      click_on t('application_form.submit')
    end

    it 'can see that the application has been successfully submitted' do
      expect(page).to have_content t('application_form.application_submitted')
    end
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
end
