require 'rails_helper'

RSpec.feature 'Candidate is redirected correctly', continuous_applications: false do
  include CandidateHelper

  it 'Candidate reviews completed application and updates qualification details section' do
    given_i_am_signed_in
    when_i_have_completed_my_application
    and_i_review_my_application
    then_i_should_see_all_sections_are_complete

    # GCSE English equivalent qualification
    when_i_click_change_english_gcse_qualification
    then_i_should_see_the_gcse_type_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_english_gcse_qualification
    then_i_should_see_the_gcse_country_form

    when_i_navigate_back_to_the_gcse_review_page
    then_i_should_see_my_updated_gcse_qualification

    # GCSE English equivalent country
    when_i_click_change_english_gcse_country
    then_i_should_see_the_gcse_country_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_english_gcse_country
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_gcse_country

    # GCSE English equivalent ENIC statement
    when_i_click_change_enic_statement
    then_i_should_see_the_gcse_enic_statement_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_enic_statement
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_enic_statement

    # GCSE English equivalent grade
    when_i_click_change_english_gcse_grade
    then_i_should_see_the_gcse_grade_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_english_gcse_grade
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_gcse_grade

    # GCSE English equivalent year awarded
    when_i_click_change_english_gcse_year
    then_i_should_see_the_gcse_year_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_english_gcse_year
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_gcse_year

    # Other qualifications type
    when_i_click_change_other_qualification_type
    then_i_should_see_the_other_qualification_type_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_the_other_qualification_type
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_qualification_type

    # Other qualifications grade
    when_i_click_change_other_qualification_grade
    then_i_should_see_the_other_qualification_details_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_the_other_qualification_grade
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_qualification_grade

    # Degree level
    when_i_click_change_degree_level
    then_i_should_see_the_degree_level_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_the_degree_level
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_degree_level

    # Degree subject
    when_i_click_change_degree_subject
    then_i_should_see_the_degree_subject_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_the_degree_subject
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_degree_subject

    # Degree university
    when_i_click_change_degree_university
    then_i_should_see_the_degree_university_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_the_degree_university
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_degree_university

    # Degree completion status
    when_i_click_change_degree_completion_status
    then_i_should_see_the_degree_completion_status_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_degree_completion_status

    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_degree_completion_status

    # Degree grade
    when_i_click_change_degree_grade
    then_i_should_see_the_degree_grade_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_degree_grade
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_degree_grade

    # Degree start year
    when_i_click_change_degree_start_year
    then_i_should_see_the_degree_start_year_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_degree_start_year
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_degree_start_year

    # Degree ENIC comparability
    when_i_change_to_an_international_degree

    when_i_click_change_degree_enic_comparability
    then_i_should_see_the_degree_enic_comparability_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_the_degree_enic_comparability
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_degree_enic_comparability
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_have_completed_my_application
    candidate_completes_application_form
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_check_your_answers
    click_link 'Check and submit your application'
  end

  def and_i_review_my_application
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  def then_i_should_see_all_sections_are_complete
    application_form_sections.each do |section|
      expect(page).not_to have_selector "[data-qa='incomplete-#{section}']"
    end
  end

  def when_i_click_back
    click_link 'Back'
  end

  def then_i_should_be_redirected_to_the_application_review_page
    expect(page).to have_current_path(candidate_interface_application_review_path)
  end

  def when_i_click_change_english_gcse_qualification
    within('[data-qa="gcse-english-qualification"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_english_gcse_country
    within('[data-qa="gcse-country"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_enic_statement
    within('[data-qa="gcse-enic-statement"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_english_gcse_grade
    within('[data-qa="gcse-english-grade"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_english_gcse_year
    within('[data-qa="gcse-english-award-year"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_other_qualification_type
    within('[data-qa="other-qualifications-type"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_other_qualification_grade
    within('[data-qa="other-qualifications-grade"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_degree_level
    within('[data-qa="degree-type"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_degree_subject
    within('[data-qa="degree-subject"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_degree_university
    within('[data-qa="degree-institution"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_degree_completion_status
    within('[data-qa="degree-completion-status"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_degree_grade
    within('[data-qa="degree-grade"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_degree_start_year
    within('[data-qa="degree-start-year"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_degree_enic_comparability
    within('[data-qa="degree-enic-comparability"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_degree_country
    within('[data-qa="degree-country"]') do
      click_link 'Change'
    end
  end

  def then_i_should_see_the_gcse_type_form
    expect(page).to have_current_path(candidate_interface_gcse_details_edit_type_path(subject: 'english', 'return-to' => 'application-review'))
  end

  def then_i_should_see_the_gcse_country_form
    expect(page).to have_content t('gcse_edit_institution_country.page_title', subject: 'English')
  end

  def then_i_should_see_the_gcse_enic_statement_form
    expect(page).to have_current_path(candidate_interface_gcse_details_edit_enic_path(subject: 'english', 'return-to' => 'application-review'))
  end

  def then_i_should_see_the_gcse_grade_form
    expect(page).to have_current_path(candidate_interface_edit_gcse_english_grade_path('return-to' => 'application-review'))
  end

  def then_i_should_see_the_gcse_year_form
    expect(page).to have_current_path(candidate_interface_gcse_details_edit_year_path(subject: 'english', 'return-to' => 'application-review'))
  end

  def then_i_should_see_the_other_qualification_type_form
    expect(page).to have_content(t('page_titles.other_qualifications'))
  end

  def then_i_should_see_the_other_qualification_details_form
    expect(page).to have_content('Edit First Aid Certificate qualification')
  end

  def then_i_should_see_the_degree_level_form
    expect(page).to have_content(t('page_titles.degree_level'))
  end

  def then_i_should_see_the_degree_subject_form
    expect(page).to have_content(t('page_titles.degree_subject'))
  end

  def then_i_should_see_the_degree_university_form
    expect(page).to have_content(t('page_titles.degree_university'))
  end

  def then_i_should_see_the_degree_completion_status_form
    expect(page).to have_content(t('page_titles.degree_completion_status'))
  end

  def then_i_should_see_the_degree_grade_form
    expect(page).to have_content(t('page_titles.degree_grade'))
  end

  def then_i_should_see_the_degree_start_year_form
    expect(page).to have_content(t('page_titles.what_year_did_you_start_your_degree'))
  end

  def then_i_should_see_the_degree_enic_comparability_form
    expect(page).to have_content(t('page_titles.degree_enic'))
  end

  def when_i_update_english_gcse_qualification
    when_i_click_change_english_gcse_qualification

    choose 'Qualification from outside the UK'

    within '#candidate-interface-gcse-qualification-type-form-qualification-type-non-uk-conditional' do
      fill_in 'Qualification name', with: 'School Certificate English'
    end

    click_button t('save_and_continue')
  end

  def when_i_update_english_gcse_country
    when_i_click_change_english_gcse_country

    select 'New Zealand'
    click_button t('save_and_continue')
  end

  def when_i_update_enic_statement
    when_i_click_change_enic_statement

    choose 'No'
    click_button t('save_and_continue')
  end

  def when_i_update_english_gcse_grade
    when_i_click_change_english_gcse_grade
    choose 'Other'
    fill_in 'Grade', with: 'C'
    click_button t('save_and_continue')
  end

  def when_i_update_english_gcse_year
    when_i_click_change_english_gcse_year
    fill_in 'Year', with: '1980'

    click_button t('save_and_continue')
  end

  def when_i_update_the_degree_level
    when_i_click_change_degree_level

    choose 'Master’s degree'
    click_button t('save_and_continue')
    choose 'Master of Arts (MA)'

    click_button t('save_and_continue')
  end

  def when_i_update_the_other_qualification_type
    when_i_click_change_other_qualification_type

    choose 'Qualification from outside the UK'
    within '#candidate-interface-other-qualification-type-form-qualification-type-non-uk-conditional' do
      fill_in 'Qualification name', with: 'First Aid Certificate'
    end
    click_button t('continue')
    select 'New Zealand'
    click_button t('save_and_continue')
  end

  def when_i_update_the_other_qualification_grade
    when_i_click_change_other_qualification_grade

    fill_in 'Grade', with: 'C'
    click_button t('save_and_continue')
  end

  def when_i_update_the_degree_subject
    when_i_click_change_degree_subject

    select 'Computer science', from: 'What subject is your degree?'
    click_button t('save_and_continue')
  end

  def when_i_update_the_degree_university
    when_i_click_change_degree_university

    select 'University of Warwick', from: 'candidate_interface_degree_wizard[university]'
    click_button t('save_and_continue')
  end

  def when_i_update_degree_completion_status
    when_i_click_change_degree_completion_status

    choose 'Yes'
    click_button t('save_and_continue')
    and_i_fill_out_the_graduation_year
  end

  def and_i_fill_out_the_graduation_year
    fill_in t('page_titles.what_year_did_you_graduate'), with: '2009'
    click_button t('save_and_continue')
  end

  def when_i_update_the_degree_enic_comparability
    when_i_click_change_degree_enic_comparability

    choose 'No'
    click_button t('save_and_continue')
  end

  def when_i_update_degree_grade
    when_i_click_change_degree_grade

    choose 'Distinction'
    click_button t('save_and_continue')
  end

  def when_i_update_degree_start_year
    when_i_click_change_degree_start_year

    fill_in t('page_titles.what_year_did_you_start_your_degree'), with: '2000'
    click_button t('save_and_continue')
  end

  def when_i_change_to_an_international_degree
    when_i_click_change_degree_country

    choose 'Another country'
    select 'France'
    click_button t('save_and_continue')

    select 'Mathematics', from: 'What subject is your degree?'
    click_button t('save_and_continue')

    fill_in 'candidate_interface_degree_wizard[international_type]', with: 'Diplôme'
    click_button t('save_and_continue')

    fill_in 'candidate_interface_degree_wizard[university]', with: 'University of Paris'
    click_button t('save_and_continue')

    choose 'Yes'
    click_button t('save_and_continue')

    choose 'Yes'
    fill_in 'candidate_interface_degree_wizard[other_grade]', with: '94%'
    click_button t('save_and_continue')

    fill_in t('page_titles.what_year_did_you_start_your_degree'), with: '2010'
    click_button t('save_and_continue')

    fill_in t('page_titles.what_year_did_you_graduate'), with: '2014'
    click_button t('save_and_continue')

    choose 'Yes'
    fill_in 'UK ENIC reference number', with: '0123456789'
    choose 'Doctor of Philosophy degree'
    click_button t('save_and_continue')
  end

  def when_i_navigate_back_to_the_gcse_review_page
    visit candidate_interface_application_review_path
  end

  def then_i_should_see_my_updated_gcse_qualification
    within('[data-qa="gcse-english-qualification"]') do
      expect(page).to have_content('School Certificate English')
    end
  end

  def and_i_should_see_my_updated_gcse_country
    within('[data-qa="gcse-country"]') do
      expect(page).to have_content('New Zealand')
    end
  end

  def and_i_should_see_my_updated_enic_statement
    within('[data-qa="gcse-enic-statement"]') do
      expect(page).to have_content('No')
    end
  end

  def and_i_should_see_my_updated_gcse_grade
    within('[data-qa="gcse-english-grade"]') do
      expect(page).to have_content('C')
    end
  end

  def and_i_should_see_my_updated_gcse_year
    within('[data-qa="gcse-english-award-year"]') do
      expect(page).to have_content('1980')
    end
  end

  def and_i_should_see_my_updated_qualification_type
    within('[data-qa="other-qualifications-type"]') do
      expect(page).to have_content('First Aid Certificate')
    end
  end

  def and_i_should_see_my_updated_qualification_grade
    within('[data-qa="other-qualifications-grade"]') do
      expect(page).to have_content('C')
    end
  end

  def and_i_should_see_my_updated_degree_level
    within('[data-qa="degree-type"]') do
      expect(page).to have_content('Master’s degree')
    end
  end

  def and_i_should_see_my_updated_degree_subject
    within('[data-qa="degree-subject"]') do
      expect(page).to have_content('Computer science')
    end
  end

  def and_i_should_see_my_updated_degree_university
    within('[data-qa="degree-institution"]') do
      expect(page).to have_content('University of Warwick')
    end
  end

  def and_i_should_see_my_updated_degree_completion_status
    within('[data-qa="degree-completion-status"]') do
      expect(page).to have_content('Yes')
    end
  end

  def and_i_should_see_my_updated_degree_grade
    within('[data-qa="degree-grade"]') do
      expect(page).to have_content('Distinction')
    end
  end

  def and_i_should_see_my_updated_degree_start_year
    within('[data-qa="degree-start-year"]') do
      expect(page).to have_content('2000')
    end
  end

  def and_i_should_see_my_updated_degree_enic_comparability
    within('[data-qa="degree-enic-comparability"]') do
      expect(page).to have_content('No')
    end
  end
end
