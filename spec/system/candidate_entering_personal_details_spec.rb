require 'rails_helper'

describe 'A candidate entering personal details' do
  context 'who successfully enters their details' do
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
    end

    it 'sees a summary of those details' do
      expect_summary_to_include('first_name', 'John')
    end

    context 'and wishes to amend their details' do
      it 'can go back and edit them' do
        find('#change-first_name').click
        expect(page).to have_field('First name', with: 'John')
      end
    end
  end

  context 'who leaves out a required field' do
    before do
      visit '/'
      click_on t('application_form.begin_button')
      click_on t('application_form.save_and_continue')
    end

    it 'sees an error summary with clickable links', js: true do
      expect(page).to have_content('There is a problem')
      click_on 'Enter your first name'
      expect(page).to have_selector('#personal_details_first_name:focus')
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

  # search for a <dt> with an expected name adjacent to a <dd> with an expected value
  def expect_summary_to_include(key, value)
    field_label = t("#{key}.label", scope: 'application_form.personal_details_section')
    expect(find('dt', text: field_label).find('+dd')).to have_content(value)
  end
end
