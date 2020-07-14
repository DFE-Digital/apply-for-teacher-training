require 'rails_helper'

RSpec.feature 'Entering their degrees' do
  include CandidateHelper

  scenario 'Candidate submits their international degree' do
    given_the_international_degrees_feature_flag_is_active
    given_i_am_signed_in
    and_i_visit_the_site
    when_i_click_on_degree
    then_i_see_the_undergraduate_degree_form

    # Add degree type after specifying Non-UK degree
    when_i_click_on_save_and_continue
    then_i_see_validation_errors_for_degree_type
    when_i_check_non_uk_degree
    and_i_click_on_save_and_continue
    then_i_see_validation_errors_for_qualification_type
    and_i_fill_in_the_qualification_type
    and_i_click_on_save_and_continue

    # Add subject
    then_i_can_see_the_degree_subject_page
    when_i_click_on_save_and_continue
    then_i_see_validation_errors_for_degree_subject
    when_i_fill_in_the_degree_subject
    and_i_click_on_save_and_continue

    # Add institution and country
    then_i_can_see_the_degree_institution_page
    when_i_click_on_save_and_continue
    then_i_see_validation_errors_for_degree_institution_and_country
    when_i_fill_in_the_degree_institution
    and_i_fill_in_the_country
    and_i_click_on_save_and_continue

    # Add NARIC statement
    then_i_can_see_the_naric_page
    when_i_click_on_save_and_continue
    then_i_see_validation_errors_for_naric_question
    when_i_check_yes_for_naric_statement
    and_i_click_on_save_and_continue
    then_i_see_validation_errors_for_naric_reference_and_comparable_uk_degree
    and_i_fill_in_naric_reference
    and_i_fill_in_comparable_uk_degree_type
    and_i_click_on_save_and_continue

    # Add grade
    then_i_can_see_the_degree_grade_page
    when_i_click_on_save_and_continue
    then_i_see_validation_errors_for_degree_grade
    when_i_check_other
    and_i_enter_my_grade
    and_i_click_on_save_and_continue

    # Add years
    then_i_can_see_the_start_and_graduation_year_page
    when_i_click_on_save_and_continue
    then_i_see_validation_errors_for_graduation_year
    when_i_fill_in_the_start_and_graduation_year
    and_i_click_on_save_and_continue

    # Review
    then_i_can_check_my_undergraduate_degree

    # Edit details
    when_i_click_to_change_my_undergraduate_degree_type
    then_i_see_my_undergraduate_degree_type_filled_in
    when_i_change_my_undergraduate_degree_type
    and_i_click_on_save_and_continue
    then_i_can_check_my_revised_undergraduate_degree_type

    when_i_click_to_change_my_undergraduate_degree_institution
    then_i_see_my_undergraduate_degree_institution_filled_in
    when_i_change_my_undergraduate_degree_institution_and_country
    and_i_click_on_save_and_continue
    then_i_can_check_my_revised_undergraduate_degree_institution

    when_i_click_to_change_my_naric_details
    then_i_see_my_original_naric_details_filled_in
    when_i_change_my_reference_number_and_comparable_uk_degree_type
    and_i_click_on_save_and_continue
    then_i_can_check_my_revised_naric_details

    # Mark section as complete
    when_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_i_should_see_the_form
    and_that_the_section_is_completed
  end

  def given_the_international_degrees_feature_flag_is_active
    FeatureFlag.activate :international_degrees
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_degree
    click_link 'Degree'
  end

  def then_i_see_the_undergraduate_degree_form
    expect(page).to have_content 'Add undergraduate degree'
  end

  def when_i_click_on_save_and_continue
    click_button t('application_form.degree.base.button')
  end

  def and_i_click_on_save_and_continue
    when_i_click_on_save_and_continue
  end

  def when_i_check_non_uk_degree
    choose 'Non-UK degree'
  end

  def then_i_see_validation_errors_for_degree_type
    expect(page).to have_content 'Select if this is a UK degree or not'
  end

  def then_i_see_validation_errors_for_qualification_type
    expect(page).to have_content 'Enter your qualification type'
  end

  def and_i_fill_in_the_qualification_type
    fill_in 'Type of qualification', with: 'Bachelors degree'
  end

  def then_i_can_see_the_degree_subject_page
    expect(page).to have_content 'What subject is your degree?'
  end

  def then_i_see_validation_errors_for_degree_subject
    expect(page).to have_content 'Enter your degree subject'
  end

  def when_i_fill_in_the_degree_subject
    fill_in 'What subject is your degree?', with: 'Computer Science'
  end

  def then_i_can_see_the_degree_institution_page
    expect(page).to have_content 'Which institution did you study at?'
  end

  def then_i_see_validation_errors_for_degree_institution_and_country
    expect(page).to have_content 'Enter the institution where you studied'
    expect(page).to have_content 'Enter the country where the institution is based'
  end

  def when_i_fill_in_the_degree_institution
    fill_in 'Institution name', with: 'University of Pune'
  end

  def and_i_fill_in_the_country
    select('India', from: 'In which country is this institution based?')
  end

  def then_i_can_see_the_naric_page
    expect(page).to have_content 'Do you have a NARIC statement of comparability for your degree?'
  end

  def then_i_see_validation_errors_for_naric_question
    expect(page).to have_content 'Select whether you have a UK NARIC reference number or not'
  end

  def when_i_check_yes_for_naric_statement
    choose 'Yes'
  end

  def then_i_see_validation_errors_for_naric_reference_and_comparable_uk_degree
    expect(page).to have_content 'Enter the UK NARIC reference number'
    expect(page).to have_content 'Select the comparable UK degree'
  end

  def and_i_fill_in_naric_reference
    fill_in 'UK NARIC reference number', with: '0123456789'
  end

  def and_i_fill_in_comparable_uk_degree_type
    choose 'Doctor of Philosophy degree'
  end

  def then_i_can_see_the_degree_grade_page
    expect(page).to have_content('What grade is your degree?')
  end

  def then_i_see_validation_errors_for_degree_grade
    expect(page).to have_content 'Enter your degree grade'
  end

  def when_i_check_other
    choose 'Other'
  end

  def and_i_enter_my_grade
    fill_in 'Enter your degree grade', with: '100'
  end

  def then_i_can_see_the_start_and_graduation_year_page
    expect(page).to have_content('When did you study for your degree?')
  end

  def then_i_see_validation_errors_for_graduation_year
    expect(page).to have_content 'Enter your graduation year'
  end

  def when_i_fill_in_the_start_and_graduation_year
    year_with_trailing_space = '2006 '
    year_with_preceding_space = ' 2009'
    fill_in 'Year started course', with: year_with_trailing_space
    fill_in 'Graduation year', with: year_with_preceding_space
  end

  def then_i_can_check_my_undergraduate_degree
    expect(page).to have_current_path candidate_interface_degrees_review_path
    expect(page).to have_content 'Computer Science'
  end

  def when_i_click_to_change_my_undergraduate_degree_type
    page.all('.govuk-summary-list__actions').to_a.first.click_link 'Change qualification'
  end

  def then_i_see_my_undergraduate_degree_type_filled_in
    expect(page).to have_selector("input[value='Bachelors degree']")
  end

  def when_i_change_my_undergraduate_degree_type
    fill_in 'Type of qualification', with: 'Bachelor of engineering degree'
  end

  def then_i_can_check_my_revised_undergraduate_degree_type
    expect(page).to have_content 'Bachelor of engineering degree'
  end

  def when_i_click_to_change_my_undergraduate_degree_institution
    page.all('.govuk-summary-list__actions').to_a.third.click_link 'Change institution'
  end

  def then_i_see_my_undergraduate_degree_institution_filled_in
    expect(page).to have_selector("input[value='University of Pune']")
    expect(page).to have_selector("option[selected='selected'][value='IN']")
  end

  def when_i_change_my_undergraduate_degree_institution_and_country
    fill_in 'Institution name', with: 'University of Bochum'
    select('Germany', from: 'In which country is this institution based?')
  end

  def then_i_can_check_my_revised_undergraduate_degree_institution
    expect(page).to have_content('University of Bochum, Germany')
  end

  def when_i_click_to_change_my_naric_details
    page.all('.govuk-summary-list__actions').to_a.fourth.click_link 'Change NARIC statement'
  end

  def then_i_see_my_original_naric_details_filled_in
    expect(page).to have_selector("input[value='0123456789']")
  end

  def when_i_change_my_reference_number_and_comparable_uk_degree_type
    fill_in 'UK NARIC reference number', with: '9876543210'
    choose 'Post Doctoral award'
  end

  def then_i_can_check_my_revised_naric_details
    expect(page).to have_content '9876543210'
    expect(page).to have_content 'Post Doctoral award'
  end

  def when_i_mark_this_section_as_completed
    check t('application_form.degree.review.completed_checkbox')
  end

  def and_i_click_on_continue
    click_button t('application_form.degree.review.button')
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#degree-badge-id', text: 'Completed')
  end
end
