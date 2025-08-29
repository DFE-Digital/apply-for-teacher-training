require 'rails_helper'

RSpec.describe 'Editing a degree' do
  include CandidateHelper

  before do
    given_i_am_signed_in_with_one_login
    when_i_view_the_degree_section
    and_i_create_an_international_degree
  end

  scenario 'editing international degree' do
    visit candidate_interface_degree_review_path
    and_i_click_the_degree_type_change_link
    and_i_update_the_international_degrees_degree_type
    and_i_click_on_save_and_continue
    then_i_can_check_an_additional_degree_is_not_created
  end

  scenario 'changing an international degree to a UK degree' do
    and_i_click_change_country
    and_i_choose_uk
    and_i_click_on_save_and_continue
    then_i_start_the_add_degree_flow_from_the_beginning
  end

  def then_i_start_the_add_degree_flow_from_the_beginning
    expect(page).to have_text('What type of degree is it?')
  end

  def and_i_choose_uk
    choose('United Kingdom')
  end

  def and_i_click_change_country
    click_on 'Change country'
  end

  def when_i_view_the_degree_section
    visit candidate_interface_details_path
    when_i_click_on_degree
  end

  def when_i_click_on_degree
    click_link_or_button 'Degree'
  end

  def and_i_create_an_international_degree
    and_i_answer_that_i_have_a_university_degree
    when_i_select_another_country
    and_i_click_on_save_and_continue
    when_i_fill_in_the_type_of_degree
    and_i_click_on_save_and_continue
    when_i_fill_in_the_subject
    and_i_click_on_save_and_continue
    when_i_fill_in_the_university
    and_i_click_on_save_and_continue
    when_i_choose_whether_degree_is_completed
    and_i_click_on_save_and_continue
    when_i_choose_whether_grade_was_given
    and_i_fill_in_the_grade
    and_i_click_on_save_and_continue
    when_i_fill_in_the_start_year
    and_i_click_on_save_and_continue
    when_i_fill_in_the_award_year
    and_i_click_on_save_and_continue
    when_i_check_yes_for_enic_statement
    and_i_fill_in_enic_reference_and_comparable_uk_degree_type
    and_i_click_on_save_and_continue
    then_i_can_check_my_undergraduate_degree
  end

  def and_i_click_on_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def then_i_can_check_an_additional_degree_is_not_created
    expect(page.all('.app-summary-card__header').count).to eq(1)
  end

  def when_i_select_another_country
    choose 'Another country'
    select 'France'
  end

  def when_i_fill_in_the_type
    choose 'Bachelor’s degree'
  end

  def when_i_fill_in_the_subject
    select 'History', from: 'What subject is your degree?'
  end

  def when_i_fill_in_the_type_of_degree
    fill_in 'candidate_interface_degree_form[type]', with: 'Diplôme'
  end

  def when_i_fill_in_the_university
    fill_in 'candidate_interface_degree_form[university]', with: 'University of Paris'
  end

  def and_i_fill_in_the_grade
    fill_in 'What grade did you get?', with: '94%'
  end

  def when_i_fill_in_the_start_year
    fill_in t('page_titles.what_year_did_you_start_your_degree'), with: '2006'
  end

  def when_i_fill_in_the_award_year
    fill_in t('page_titles.what_year_did_you_graduate'), with: '2009'
  end

  def when_i_choose_whether_degree_is_completed
    choose 'Yes'
  end

  def when_i_choose_whether_grade_was_given
    choose 'Yes'
  end

  def when_i_check_yes_for_enic_statement
    choose 'Yes, I have a statement of comparability'
    and_i_click_on_save_and_continue
  end

  def and_i_fill_in_enic_reference_and_comparable_uk_degree_type
    fill_in 'UK ENIC reference number', with: '0123456789'
    choose 'Doctor of Philosophy degree'
  end

  def and_i_click_the_degree_type_change_link
    all('a', text: 'Change')[1].click
  end

  def and_i_update_the_international_degrees_degree_type
    fill_in 'candidate_interface_degree_form[type]', with: 'Bachelor’s degree'
  end

  def then_i_can_check_my_undergraduate_degree
    expect(page).to have_current_path candidate_interface_degree_review_path
    expect(page).to have_content 'History'
  end
end
