require 'rails_helper'

RSpec.describe 'Entering their contact information with residency questions enabled',
               feature_flag: '2027_application_form_contact_details_residency_questions' do
  include CandidateHelper

  scenario 'Candidate submits their residency information and lives in same country or territory as one of their nationalities', :js do
    given_i_am_signed_in_with_one_login
    and_i_am_british
    and_i_visit_the_site

    when_i_click_on_contact_information
    and_i_submit_my_phone_number
    then_i_see_the_address_type_question

    when_i_select_outside_the_uk
    and_i_enter_jersey
    then_i_see_the_address_form

    when_i_fill_in_my_address
    click_link_or_button 'Save and continue'
    then_i_see_the_residency_since_birth_question

    when_i_click_back
    then_i_see_the_address_form
    click_link_or_button 'Save and continue'
    then_i_see_the_residency_since_birth_question

    when_i_answer_yes
    then_i_see_the_review_page_with_the_expected_values

    when_i_click_to_change_my_residency_response
    then_i_see_the_residency_since_birth_question

    when_i_click_back
    then_i_see_the_review_page_with_the_expected_values
  end

  scenario 'Candidate submits their residency information and lives in a different country or territory to any of their nationalities', :js do
    given_i_am_signed_in_with_one_login
    and_i_am_french
    and_i_visit_the_site

    when_i_click_on_contact_information
    and_i_submit_my_phone_number
    then_i_see_the_address_type_question

    when_i_select_outside_the_uk
    and_i_enter_jersey
    then_i_see_the_address_form

    when_i_fill_in_my_address
    click_link_or_button 'Save and continue'
    then_i_see_the_residency_dates_question

    when_i_click_back
    then_i_see_the_address_form

    click_link_or_button 'Save and continue'
    then_i_see_the_residency_dates_question

    when_i_fill_in_the_dates
    click_link_or_button 'Save and continue'
    then_i_see_the_review_page_with_expected_values_including_dates

    when_i_click_to_change_my_residency_dates_response
    then_i_see_the_residency_dates_question

    when_i_click_back
    then_i_see_the_review_page_with_expected_values_including_dates
  end

  def and_i_am_british
    @current_candidate.application_forms.last.update(first_nationality: 'British')
  end

  def and_i_am_french
    @current_candidate.application_forms.last.update(first_nationality: 'French')
  end

  def and_i_visit_the_site
    visit candidate_interface_details_path
  end

  def when_i_click_on_contact_information
    click_link_or_button 'Contact information'
  end

  def and_i_submit_my_phone_number
    fill_in 'Phone number', with: '07700 900 982'
    click_link_or_button 'Save and continue'
  end

  def then_i_see_the_address_type_question
    expect(page).to have_content('Where do you live?')
  end

  def when_i_select_outside_the_uk
    find('label', text: 'Outside the UK').click
  end

  def and_i_enter_jersey
    expect(page).to have_content('Where do you live?')

    fill_in 'Which country or territory?', with: 'Jersey'
    find('.autocomplete__option', text: 'Jersey').click
    click_link_or_button 'Save and continue'
  end

  def then_i_see_the_address_form
    expect(page).to have_content('What is your address?')
  end

  def when_i_fill_in_my_address
    fill_in 'candidate_interface_contact_details_form[address_line1]', with: '133 Rue des Peupliers'
    fill_in 'candidate_interface_contact_details_form[address_line3]', with: 'St Helier'
    fill_in 'candidate_interface_contact_details_form[address_line4]', with: 'JE1 0FS'
  end

  def then_i_see_the_residency_since_birth_question
    expect(page).to have_content('Have you lived in Jersey since birth?')
  end

  def when_i_click_back
    click_link_or_button 'Back'
  end

  def when_i_answer_yes
    find('label', text: 'Yes').click
    click_link_or_button 'Save and continue'
  end

  def then_i_see_the_review_page_with_the_expected_values
    expect(page).to have_content('Check your contact information')

    within("[data-qa='contact-details-residency']") do
      expect(page).to have_content('Have you lived in Jersey since birth?')
      expect(page).to have_content('Yes')
    end

    expect(page).to have_no_content('From what date have you lived in Jersey?')
  end

  def when_i_click_to_change_my_residency_response
    within("[data-qa='contact-details-residency']") do
      click_link_or_button 'Change'
    end
  end

  def then_i_see_the_residency_dates_question
    expect(page).to have_content('From what date have you lived in Jersey?')
  end

  def when_i_fill_in_the_dates
    fill_in 'Month', with: '10'
    fill_in 'Year', with: '2003'
  end

  def then_i_see_the_review_page_with_expected_values_including_dates
    expect(page).to have_content('Check your contact information')

    within("[data-qa='contact-details-residency']") do
      expect(page).to have_content('Have you lived in Jersey since birth?')
      expect(page).to have_content('No')
    end

    within("[data-qa='contact-details-residency-date']") do
      expect(page).to have_content('Lived in Jersey since')
      expect(page).to have_content('October 2003')
    end
  end

  def when_i_click_to_change_my_residency_dates_response
    within("[data-qa='contact-details-residency-date']") do
      click_link_or_button 'Change'
    end
  end
end
