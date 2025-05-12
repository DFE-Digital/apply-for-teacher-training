require 'rails_helper'

RSpec.describe 'Entering an international doctorate degree' do
  include CandidateHelper

  scenario 'Candidate enters their degree without an enic reason' do
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
    and_i_dont_select_an_enic_reason
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
    click_on 'Continue'
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

  def and_i_dont_select_an_enic_reason
    and_i_click_on_save_and_continue
    expect(page).to have_content 'Select whether you have a UK ENIC reference number or not'
  end
end
