require 'rails_helper'

RSpec.describe 'Entering an international doctorate degree' do
  include CandidateHelper

  scenario 'Candidate enters their degree' do
    given_i_am_signed_in_with_one_login
    when_i_view_the_degree_section
    and_i_answer_that_i_have_a_university_degree
    and_i_select_another_country
    and_i_fill_in_the_type_of_degree
    and_i_fill_in_the_subject
    and_i_fill_in_the_university
    and_i_choose_whether_degree_is_completed
    and_i_select_no_grade_was_given
    and_i_fill_in_the_start_year
    when_i_fill_in_the_award_year
    and_i_check_no_for_enic_statement

    then_i_can_check_my_international_degree

    when_i_change_my_degree_grade_to_not_known
    then_i_can_check_the_grade_has_changed

    when_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_i_see_the_form
    and_that_the_section_is_completed
    when_i_click_on_degree
    then_i_can_check_my_answers
  end

private

  def when_i_view_the_degree_section
    visit candidate_interface_details_path
    when_i_click_on_degree
  end

  def when_i_click_on_degree
    click_link_or_button 'Degree'
  end

  def and_i_click_add_degree
    click_link_or_button 'Add a degree'
  end

  def and_i_select_another_country
    choose 'Another country'
    select 'France'
    and_i_click_on_save_and_continue
  end

  def and_i_click_on_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def and_i_click_on_continue
    click_on 'Save changes and return to your details'
  end

  def when_i_fill_in_the_type
    choose 'Doctor of Philosophy'
  end

  def then_i_can_see_the_subject_page
    expect(page).to have_content 'What subject is your degree?'
  end

  def and_i_fill_in_the_subject
    select 'History', from: 'What subject is your degree?'
    and_i_click_on_save_and_continue
  end

  def and_i_fill_in_the_type_of_degree
    fill_in 'candidate_interface_degree_wizard[international_type]', with: 'Doctorate of Philosophy'
    and_i_click_on_save_and_continue
  end

  def and_i_fill_in_the_university
    fill_in 'candidate_interface_degree_wizard[university]', with: 'Purdue University'
    and_i_click_on_save_and_continue
  end

  def and_i_choose_whether_degree_is_completed
    choose 'Yes'
    and_i_click_on_save_and_continue
  end

  def and_i_select_no_grade_was_given
    choose 'No'
    and_i_click_on_save_and_continue
  end

  def and_i_fill_in_the_start_year
    fill_in t('page_titles.what_year_did_you_start_your_degree'), with: '2006'
    and_i_click_on_save_and_continue
  end

  def when_i_fill_in_the_award_year
    fill_in t('page_titles.what_year_did_you_graduate'), with: '2009'
    and_i_click_on_save_and_continue
  end

  def and_i_check_no_for_enic_statement
    choose 'I do not need a statement of comparability'
    and_i_click_on_save_and_continue
  end

  def when_i_mark_this_section_as_completed
    choose t('application_form.completed_radio')
  end

  def then_i_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#degree-badge-id', text: 'Completed')
  end

  def then_i_can_check_my_international_degree
    expect(page).to have_current_path candidate_interface_degree_review_path
    expect(page).to have_content 'History'
    within '[data-qa="degree-grade"]' do
      expect(page).to have_content 'Grade'
      expect(page).to have_content 'N/A'
    end
  end

  def when_i_change_my_degree_grade_to_not_known
    within '[data-qa="degree-grade"]' do
      click_on 'Change'
    end
    choose 'I do not know'
    and_i_click_on_save_and_continue
  end

  def then_i_can_check_the_grade_has_changed
    expect(page).to have_current_path candidate_interface_degree_review_path
    expect(page).to have_content 'History'
    within '[data-qa="degree-grade"]' do
      expect(page).to have_content 'Grade'
      expect(page).to have_content 'Unknown'
    end
  end

  def then_i_can_check_my_answers
    expect(page).to have_content 'France'
    within '[data-qa="degree-type"]' do
      expect(page).to have_content 'Doctor'
    end
    expect(page).to have_content 'Purdue University'
    expect(page).to have_content 'Doctorate of Philosophy, History,'
    expect(page).to have_content '2006'
    expect(page).to have_content '2009'
  end
end
