require 'rails_helper'

RSpec.describe 'Entering an international degree' do
  include CandidateHelper

  scenario 'Candidate enters their degree' do
    given_i_am_signed_in
    when_i_view_the_degree_section

    and_i_answer_that_i_have_a_university_degree

    # Add country
    then_i_can_see_the_country_page
    when_i_select_another_country
    and_i_click_on_save_and_continue

    # Add degree type
    then_i_can_see_the_type_page
    when_i_fill_in_the_type_of_degree
    and_i_click_on_save_and_continue

    # Add subject
    then_i_can_see_the_subject_page
    when_i_fill_in_the_subject
    and_i_click_on_save_and_continue

    # Add university
    then_i_can_see_the_university_page
    when_i_fill_in_the_university
    and_i_click_on_save_and_continue

    # Add completion
    then_i_can_see_the_completion_page
    when_i_choose_whether_degree_is_completed
    and_i_click_on_save_and_continue

    # Add grade
    then_i_can_see_the_grade_page
    when_i_choose_whether_grade_was_given
    and_i_fill_in_the_grade
    and_i_click_on_save_and_continue

    # Add start year
    then_i_can_see_the_start_year_page
    when_i_fill_in_the_start_year
    and_i_click_on_save_and_continue

    # Add award year
    then_i_can_see_the_award_year_page
    when_i_fill_in_the_award_year
    and_i_click_on_save_and_continue

    # Add enic
    then_i_can_see_the_enic_page
    when_i_check_yes_for_enic_statement
    and_i_click_on_save_and_continue
    and_i_fill_in_enic_reference
    and_i_fill_in_comparable_uk_degree_type
    and_i_click_on_save_and_continue

    # Review
    then_i_can_check_my_undergraduate_degree

    # Mark section as complete
    when_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_i_see_the_form
    and_that_the_section_is_completed
    when_i_click_on_degree
    then_i_can_check_my_answers
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_view_the_degree_section
    visit candidate_interface_details_path
    when_i_click_on_degree
  end

  def when_i_click_on_degree
    click_link_or_button 'Degree'
  end

  def then_i_can_see_the_country_page
    expect(page).to have_content('Which country was the degree from?')
  end

  def when_i_select_another_country
    choose 'Another country'
    select 'France'
  end

  def and_i_click_on_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def when_i_click_on_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def when_i_fill_in_the_type
    choose 'Bachelor degree'
  end

  def then_i_can_see_the_subject_page
    expect(page).to have_content 'What subject is your degree?'
  end

  def when_i_fill_in_the_subject
    select 'History', from: 'What subject is your degree?'
  end

  def then_i_can_see_the_type_page
    expect(page).to have_content 'What type of degree is it?'
  end

  def when_i_fill_in_the_type_of_degree
    fill_in 'candidate_interface_degree_wizard[international_type]', with: 'Diplôme'
  end

  def then_i_can_see_the_university_page
    expect(page).to have_content 'Which university awarded your degree?'
  end

  def when_i_fill_in_the_university
    fill_in 'candidate_interface_degree_wizard[university]', with: 'University of Paris'
  end

  def then_i_can_see_the_completion_page
    expect(page).to have_content 'Have you completed your degree?'
  end

  def when_i_choose_whether_degree_is_completed
    choose 'Yes'
  end

  def then_i_can_see_the_grade_page
    expect(page).to have_content('Did your degree give a grade?')
  end

  def when_i_choose_whether_grade_was_given
    choose 'Yes'
  end

  def and_i_fill_in_the_grade
    fill_in 'What grade did you get?', with: '94%'
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

  def then_i_can_see_the_enic_page
    expect(page).to have_content 'Do you have a statement of comparability from UK ENIC'
  end

  def when_i_check_yes_for_enic_statement
    choose 'Yes, I have a statement of comparability'
  end

  def and_i_fill_in_enic_reference
    fill_in 'UK ENIC reference number', with: '0123456789'
  end

  def and_i_fill_in_comparable_uk_degree_type
    choose 'Doctor of Philosophy degree'
  end

  def then_i_can_check_my_undergraduate_degree
    expect(page).to have_current_path candidate_interface_degree_review_path
    expect(page).to have_content 'History'
  end

  def when_i_click_on_continue
    click_link_or_button t('continue')
  end

  def and_i_click_on_continue
    when_i_click_on_continue
  end

  def when_i_mark_this_section_as_completed
    choose t('application_form.completed_radio')
  end

  def and_i_click_on_continue
    when_i_click_on_continue
  end

  def then_i_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#degree-badge-id', text: 'Completed')
  end

  def then_i_can_check_my_answers
    expect(page).to have_content 'France'
    expect(page).to have_content 'Diplôme'
    expect(page).to have_content 'University of Paris'
    expect(page).to have_content 'Doctor of Philosophy degree'
    expect(page).to have_content '0123456789'
    expect(page).to have_content '94%'
    expect(page).to have_content '2006'
    expect(page).to have_content '2009'
  end
end
