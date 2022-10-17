require 'rails_helper'

RSpec.feature 'Editing a degree' do
  include CandidateHelper

  before do
    allow(CycleTimetable).to receive(:current_year).and_return(2022)
  end

  scenario 'editing international degree' do
    given_i_am_signed_in
    when_i_view_the_degree_section
    and_i_create_an_international_degree
    and_when_i_click_the_browser_back_button
    and_i_click_on_save_and_continue
    then_i_can_check_an_additional_degree_is_not_created
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def when_i_view_the_degree_section
    visit candidate_interface_application_form_path
    when_i_click_on_degree
  end

  def when_i_click_on_degree
    click_link 'Degree'
  end

  def and_i_create_an_international_degree
    and_i_click_add_degree
    when_i_select_another_country
    and_i_click_on_save_and_continue
    when_i_fill_in_the_subject
    and_i_click_on_save_and_continue
    when_i_fill_in_the_type_of_degree
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
    and_i_fill_in_enic_reference
    and_i_fill_in_comparable_uk_degree_type
    and_i_click_on_save_and_continue
    then_i_can_check_my_undergraduate_degree
  end

  def and_when_i_click_the_browser_back_button
    visit candidate_interface_new_degree_enic_path
  end

  def and_i_click_on_save_and_continue
    click_button t('save_and_continue')
  end

  def then_i_can_check_an_additional_degree_is_not_created
    expect(page.all('.app-summary-card__header').count).to eq(1)
  end

  def and_i_click_add_degree
    click_link 'Add a degree'
  end

  def when_i_select_another_country
    choose 'Another country'
    select 'France'
  end

  def when_i_fill_in_the_type
    choose 'Bachelor degree'
  end

  def when_i_fill_in_the_subject
    select 'History', from: 'What subject is your degree?'
  end

  def when_i_fill_in_the_type_of_degree
    fill_in 'candidate_interface_degree_wizard[international_type]', with: 'Diplôme'
  end

  def when_i_fill_in_the_university
    fill_in 'candidate_interface_degree_wizard[university]', with: 'University of Paris'
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
    choose 'Yes'
  end

  def and_i_fill_in_enic_reference
    fill_in 'UK ENIC reference number', with: '0123456789'
  end

  def and_i_fill_in_comparable_uk_degree_type
    choose 'Doctor of Philosophy degree'
  end

  def then_i_can_check_my_undergraduate_degree
    expect(page).to have_current_path candidate_interface_new_degree_review_path
    expect(page).to have_content 'History'
  end
end
