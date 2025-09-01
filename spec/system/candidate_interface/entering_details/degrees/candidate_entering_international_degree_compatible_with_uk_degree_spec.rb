require 'rails_helper'

RSpec.describe 'Entering an international degree from a country with uk compatible degrees' do
  include CandidateHelper

  scenario 'From country with compatible degrees, select bachelor' do
    given_i_am_signed_in_with_one_login
    when_i_view_the_degree_section
    and_i_answer_that_i_have_a_university_degree

    # Add country
    then_i_can_see_the_country_page
    when_i_choose_country_with_compatible_degrees
    and_i_click_on_save_and_continue

    # Add degree level
    then_i_can_see_the_level_page
    when_i_choose_bachelors_degree
    and_i_click_on_save_and_continue

    # Add type
    then_i_see_the_type_page_for_a_bachelors_degree
    when_i_choose_the_type_of_degree
    and_i_click_on_save_and_continue

    # Add subject
    then_i_can_see_the_subject_page
    when_i_fill_in_the_subject
    and_i_click_on_save_and_continue

    # Add university
    then_i_can_see_the_university_page
    when_i_enter_a_university
    and_i_click_on_save_and_continue

    # Add completion
    then_i_can_see_the_completion_page
    when_i_choose_the_degree_is_complete
    and_i_click_on_save_and_continue

    # Add grade
    then_i_can_see_the_uk_grade_page
    when_i_select_the_grade
    and_i_click_on_save_and_continue

    # Add start year
    then_i_can_see_the_start_year_page
    when_i_fill_in_the_start_year
    and_i_click_on_save_and_continue

    # Add award year
    then_i_can_see_the_award_year_page
    when_i_fill_in_the_award_year
    and_i_click_on_save_and_continue

    # Add an Enic reason
    then_i_see_the_enic_reason_page
    when_i_select_obtained
    and_i_click_on_save_and_continue

    # Add Enic reference details
    then_i_see_the_enic_reference_page
    when_i_enter_an_enic_reference_and_comparable_degree
    and_i_click_on_save_and_continue

    # Review
    then_i_see_the_review_page
    and_my_degree_has_been_saved_with_comparable_details
  end

  scenario 'From country with compatible degrees, selects other' do
    given_i_am_signed_in_with_one_login
    when_i_view_the_degree_section
    and_i_answer_that_i_have_a_university_degree

    # Add country
    then_i_can_see_the_country_page
    when_i_choose_country_with_compatible_degrees
    and_i_click_on_save_and_continue

    # Add degree level
    then_i_can_see_the_level_page
    when_i_choose_other_degree
    and_i_click_on_save_and_continue

    # Add type
    then_i_can_see_the_international_type_page
    when_i_fill_in_a_degree_type
    and_i_click_on_save_and_continue

    # Add subject
    then_i_can_see_the_subject_page
    when_i_fill_in_the_subject
    and_i_click_on_save_and_continue

    # Add university
    then_i_can_see_the_university_page
    when_i_enter_a_university
    and_i_click_on_save_and_continue

    # Add completion
    then_i_can_see_the_completion_page
    when_i_choose_the_degree_is_complete
    and_i_click_on_save_and_continue

    # Add grade
    then_i_can_see_the_international_grade_page
    when_i_select_yes_and_enter_a_grade
    and_i_click_on_save_and_continue

    # Add start year
    then_i_can_see_the_start_year_page
    when_i_fill_in_the_start_year
    and_i_click_on_save_and_continue

    # Add award year
    then_i_can_see_the_award_year_page
    when_i_fill_in_the_award_year
    and_i_click_on_save_and_continue

    # Add an Enic reason
    then_i_see_the_enic_reason_page
    when_i_select_obtained
    and_i_click_on_save_and_continue

    # Add Enic reference details
    then_i_see_the_enic_reference_page
    when_i_enter_an_enic_reference_and_comparable_degree
    and_i_click_on_save_and_continue

    # Review page
    then_i_see_the_other_degree_review_page
    and_my_other_degree_has_been_saved_with_international_details
  end

private

  def then_i_see_the_other_degree_review_page
    expect(page).to have_content 'Check your degree'
    expect(page).to have_content '3.9 GPA'
    expect(page).to have_content 'Licenciatura'
    expect(page).to have_content 'University of Ghana'
    expect(page).to have_content '4000228363'
    expect(page).to have_content 'Bachelor (Honours) degree'
  end

  def and_my_other_degree_has_been_saved_with_international_details
    degree = ApplicationQualification.where(level: 'degree').last
    expect(degree.qualification_type_hesa_code).to be_nil
    expect(degree.degree_type_uuid).to be_nil
    expect(degree.degree_subject_uuid).to eq '1b8670f0-5dce-e911-a985-000d3ab79618'
    expect(degree.degree_grade_uuid).to be_nil
  end

  def then_i_can_see_the_international_type_page
    expect(page).to have_content 'What type of degree is it?'
  end

  def when_i_fill_in_a_degree_type
    fill_in 'What type of degree is it?', with: 'Licenciatura'
  end

  def when_i_view_the_degree_section
    visit candidate_interface_details_path
    click_link_or_button 'Degree'
  end

  def then_i_can_see_the_country_page
    expect(page).to have_content('Which country was the degree from?')
  end

  def and_i_click_on_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def then_i_can_see_the_level_page
    expect(page).to have_content 'What type of degree is it?'
  end

  def then_i_see_the_type_page_for_a_bachelors_degree
    expect(page).to have_content 'What type of bachelor’s degree is it?'
  end

  def when_i_choose_the_type_of_degree
    choose 'Bachelor of Arts (BA)'
  end

  def when_i_fill_in_the_subject
    select 'French history', from: 'What subject is your degree?'
  end

  def then_i_can_see_the_subject_page
    expect(page).to have_content 'What subject is your degree?'
  end

  def then_i_see_the_review_page
    expect(page).to have_content 'Check your degree'
    expect(page).to have_content 'First-class honours'
    expect(page).to have_content 'University of Ghana'
    expect(page).to have_content '4000228363'
    expect(page).to have_content 'Bachelor (Honours) degree'
  end

  def and_my_degree_has_been_saved_with_comparable_details
    degree = ApplicationQualification.where(level: 'degree').last
    expect(degree.qualification_type_hesa_code).to eq '051'
    expect(degree.degree_type_uuid).to eq 'db695652-c197-e711-80d8-005056ac45bb'
    expect(degree.degree_subject_uuid).to eq '1b8670f0-5dce-e911-a985-000d3ab79618'
    expect(degree.degree_grade_uuid).to eq '8741765a-13d8-4550-a413-c5a860a59d25'
  end

  def then_i_see_the_enic_reason_page
    expect(page).to have_content 'Show how your degree compares to a UK degree'
  end

  def when_i_select_obtained
    choose 'Yes, I have a statement of comparability'
  end

  def then_i_see_the_enic_reference_page
    expect(page).to have_content 'Enter the UK ENIC reference number for your degree'
  end

  def when_i_enter_an_enic_reference_and_comparable_degree
    fill_in 'UK ENIC reference number', with: '4000228363'
    choose 'Bachelor (Honours) degree'
  end

  def then_i_can_see_the_start_year_page
    expect(page).to have_content('What year did you start your degree?')
  end

  def when_i_fill_in_the_start_year
    fill_in t('page_titles.what_year_did_you_start_your_degree'), with: '2006'
  end

  def then_i_can_see_the_award_year_page
    expect(page).to have_content('What year did you graduate?')
  end

  def when_i_fill_in_the_award_year
    fill_in t('page_titles.what_year_did_you_graduate'), with: '2009'
  end

  def when_i_choose_country_with_compatible_degrees
    choose 'Another country'
    select 'Ghana'
  end

  def when_i_choose_bachelors_degree
    choose 'Bachelor’s degree'
  end

  def when_i_choose_other_degree
    choose 'Other'
  end

  def when_i_choose_other_degree
    choose 'Other'
  end

  def then_i_can_see_the_university_page
    expect(page).to have_content 'Which university awarded your degree?'
  end

  def when_i_enter_a_university
    fill_in 'Which university awarded your degree?', with: 'University of Ghana'
  end

  def then_i_can_see_the_completion_page
    expect(page).to have_content 'Have you completed your degree?'
  end

  def when_i_choose_the_degree_is_complete
    choose 'Yes'
  end

  def then_i_can_see_the_international_grade_page
    expect(page).to have_content 'Did your degree give a grade?'
  end

  def when_i_select_yes_and_enter_a_grade
    choose 'Yes'
    fill_in 'What grade did you get?', with: '3.9 GPA'
  end

  def then_i_can_see_the_uk_grade_page
    expect(page).to have_content 'What grade is your degree?'
  end

  def when_i_select_the_grade
    choose 'First-class honours', visible: false
  end
end
