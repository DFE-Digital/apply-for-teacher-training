require 'rails_helper'

RSpec.describe 'Entering a PhD' do
  include CandidateHelper

  scenario 'Candidate enters their PhD' do
    given_i_am_signed_in_with_one_login
    when_i_view_the_degree_section

    and_i_answer_that_i_have_a_university_degree

    # Add country
    then_i_can_see_the_country_page
    when_i_choose_united_kingdom
    and_i_click_on_save_and_continue

    # Add degree level
    then_i_can_see_the_level_page
    when_i_choose_the_phd_level
    and_i_click_on_save_and_continue

    # Add degree type
    then_i_can_see_the_type_page
    when_i_choose_the_type_of_degree
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

    # Add start year
    then_i_can_see_the_start_year_page
    when_i_click_the_back_link
    then_i_can_see_the_completion_page
    and_i_click_on_save_and_continue

    then_i_can_see_the_start_year_page
    when_i_fill_in_the_start_year
    and_i_click_on_save_and_continue

    # Add award year
    then_i_can_see_the_award_year_page
    when_i_fill_in_the_award_year
    and_i_click_on_save_and_continue

    # Review
    then_i_can_check_my_phd
  end

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

  def then_i_can_see_the_country_page
    expect(page).to have_content('Which country was the degree from?')
  end

  def when_i_choose_united_kingdom
    choose 'United Kingdom'
  end

  def and_i_click_on_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def when_i_click_on_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def then_i_can_see_the_level_page
    expect(page).to have_content 'What type of degree is it?'
  end

  def when_i_choose_the_phd_level
    choose 'Doctorate (PhD)'
  end

  def then_i_can_see_the_subject_page
    expect(page).to have_content 'What subject is your degree?'
  end

  def when_i_fill_in_the_subject
    select 'History', from: 'What subject is your degree?'
  end

  def then_i_can_see_the_type_page
    expect(page).to have_content 'What type of doctorate is it?'
  end

  def when_i_choose_the_type_of_degree
    choose 'Doctor of Philosophy (DPhil)'
  end

  def then_i_can_see_the_university_page
    expect(page).to have_content 'Which university awarded your degree?'
  end

  def when_i_fill_in_the_university
    select 'University of Cambridge', from: 'candidate_interface_degree_form[university]'
  end

  def then_i_can_see_the_completion_page
    expect(page).to have_content 'Have you completed your degree?'
  end

  def when_i_choose_whether_degree_is_completed
    choose 'Yes'
  end

  def then_i_can_see_the_start_year_page
    expect(page).to have_content('What year did you start your degree?')
  end

  def when_i_click_the_back_link
    click_link_or_button 'Back'
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

  def then_i_can_check_my_phd
    expect(page).to have_current_path candidate_interface_degree_review_path
    expect(page).to have_content 'History'
  end
end
