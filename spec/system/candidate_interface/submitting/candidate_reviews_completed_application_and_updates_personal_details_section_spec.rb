require 'rails_helper'

RSpec.feature 'Candidate is redirected correctly' do
  include CandidateHelper

  scenario 'Candidate reviews completed application and updates personal details section' do
    given_i_am_signed_in
    when_i_have_completed_my_application
    and_i_review_my_application
    then_i_should_see_all_sections_are_complete

    # name
    when_i_click_change_name
    then_i_should_see_the_personal_details_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_my_name
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_name

    # date of birth
    when_i_click_change_date_of_birth
    then_i_should_see_the_personal_details_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_my_date_of_birth
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_date_of_birth

    # nationality
    when_i_click_change_nationality
    then_i_should_see_the_nationality_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_my_nationality
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_nationality

    # languages
    when_i_click_change_language
    then_i_should_see_the_language_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_my_language
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_language

    # phone number
    when_i_click_change_phone_number
    then_i_should_see_the_phone_number_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_my_phone_number
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_phone_number

    # address
    when_i_click_change_address
    then_i_should_see_the_address_type_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_my_address
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_address
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_have_completed_my_application
    candidate_completes_application_form
  end

  def and_i_review_my_application
    allow(LanguagesSectionPolicy).to receive(:hide?).and_return(false)
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  def then_i_should_see_all_sections_are_complete
    application_form_sections.each do |section|
      expect(page).not_to have_selector "[data-qa='incomplete-#{section}']"
    end
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_check_your_answers
    click_link 'Check and submit your application'
  end

  def when_i_click_change_name
    within('[data-qa="personal-details-name"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_date_of_birth
    within('[data-qa="personal-details-dob"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_nationality
    within('[data-qa="personal-details-nationality"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_language
    within('[data-qa="personal-details-english-main-language"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_phone_number
    within('[data-qa="contact-details-phone-number"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_address
    within('[data-qa="contact-details-address"]') do
      click_link 'Change'
    end
  end

  def then_i_should_see_the_personal_details_form
    expect(page).to have_current_path(candidate_interface_edit_name_and_dob_path('return-to' => 'application-review'))
  end

  def then_i_should_see_the_nationality_form
    expect(page).to have_current_path(candidate_interface_edit_nationalities_path('return-to' => 'application-review'))
  end

  def then_i_should_see_the_language_form
    expect(page).to have_current_path(candidate_interface_edit_languages_path('return-to' => 'application-review'))
  end

  def then_i_should_see_the_phone_number_form
    expect(page).to have_current_path(candidate_interface_edit_phone_number_path('return-to' => 'application-review'))
  end

  def then_i_should_see_the_address_type_form
    expect(page).to have_current_path(candidate_interface_edit_address_type_path('return-to' => 'application-review'))
  end

  def when_i_click_back
    click_link 'Back'
  end

  def then_i_should_be_redirected_to_the_application_review_page
    expect(page).to have_current_path(candidate_interface_application_review_path)
  end

  def when_i_update_my_name
    when_i_click_change_name
    fill_in 'First name', with: 'Ruddeger'
    click_button 'Save and continue'
  end

  def when_i_update_my_date_of_birth
    when_i_click_change_date_of_birth
    fill_in 'Day', with: '2'
    click_button 'Save and continue'
  end

  def when_i_update_my_nationality
    when_i_click_change_nationality

    check 'Irish'
    click_button 'Save and continue'
  end

  def when_i_update_my_language
    when_i_click_change_language

    choose 'No'
    click_button 'Save and continue'
  end

  def when_i_update_my_phone_number
    when_i_click_change_phone_number

    fill_in 'Phone number', with: '0736519012'
    click_button 'Save and continue'
  end

  def when_i_update_my_address
    when_i_click_change_address

    click_button 'Save and continue'
    fill_in 'Town or city', with: 'Auckland'
    click_button 'Save and continue'
  end

  def and_i_should_see_my_updated_name
    within('[data-qa="personal-details-name"]') do
      expect(page).to have_content('Ruddeger')
    end
  end

  def and_i_should_see_my_updated_date_of_birth
    within('[data-qa="personal-details-dob"]') do
      expect(page).to have_content('2')
    end
  end

  def and_i_should_see_my_updated_nationality
    within('[data-qa="personal-details-nationality"]') do
      expect(page).to have_content('Irish')
    end
  end

  def and_i_should_see_my_updated_language
    within('[data-qa="personal-details-english-main-language"]') do
      expect(page).to have_content('No')
    end
  end

  def and_i_should_see_my_updated_phone_number
    within('[data-qa="contact-details-phone-number"]') do
      expect(page).to have_content('0736519012')
    end
  end

  def and_i_should_see_my_updated_address
    within('[data-qa="contact-details-address"]') do
      expect(page).to have_content('Auckland')
    end
  end
end
