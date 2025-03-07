require 'rails_helper'

RSpec.describe 'Adding an unknown degree', :js do
  include CandidateHelper

  scenario 'Candidate enters their degree' do
    given_i_am_signed_in_with_one_login
    when_i_view_the_degree_section

    and_i_answer_that_i_have_a_university_degree

    # Add country
    then_i_can_see_the_country_page
    when_i_choose_united_kingdom
    and_i_click_on_save_and_continue

    # Add degree level
    then_i_can_see_the_level_page
    when_i_choose_the_level
    and_i_click_on_save_and_continue

    # Add subject
    then_i_can_see_the_subject_page
    when_i_fill_in_the_subject
    and_i_click_on_save_and_continue

    # Add degree type
    then_i_can_see_the_type_page
    when_i_choose_an_unknown_type_of_degree
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

    # Review
    then_i_can_check_my_undergraduate_degree

    # Mark section as complete
    when_i_mark_this_section_as_completed
    and_i_click_on_save_changes_and_return
    then_i_see_the_form
    and_that_the_section_is_completed
    when_i_click_on_degree
    then_i_can_check_my_answers
  end

  # https://trello.com/c/MaFJIstY/871-custom-degree-subjects-sometimes-cannot-be-entered-by-candidates
  scenario 'Candidate enters a custom degree subject that has an incorrect auto-suggestion' do
    given_i_am_at_the_degree_subject_page
    when_i_fill_in_the_subject_with_a_custom_subject_that_has_an_incorrect_auto_suggestion
    then_the_custom_subject_remains_filled_in
  end

  def given_i_am_at_the_degree_subject_page
    given_i_am_signed_in_with_one_login
    when_i_view_the_degree_section

    and_i_answer_that_i_have_a_university_degree

    # Add country
    then_i_can_see_the_country_page
    when_i_choose_united_kingdom
    and_i_click_on_save_and_continue

    # Add degree level
    then_i_can_see_the_level_page
    when_i_choose_the_level
    and_i_click_on_save_and_continue
  end

  def when_i_fill_in_the_subject_with_a_custom_subject_that_has_an_incorrect_auto_suggestion
    @input = find('input[name="candidate_interface_degree_wizard[subject_raw]"]')
    @input.native.send_keys('History of Art and History')
    find_by_id('main-content').click
  end

  def then_the_custom_subject_remains_filled_in
    expect(@input.value).to eq('History of Art and History')
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

  def when_i_choose_united_kingdom
    choose 'United Kingdom', visible: false
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

  def when_i_choose_the_level
    choose 'Bachelor', visible: false
  end

  def then_i_can_see_the_subject_page
    expect(page).to have_content 'What subject is your degree?'
  end

  def when_i_fill_in_the_subject
    fill_in 'What subject is your degree?', with: 'History'
    # Triggering the autocomplete
    find('input[name="candidate_interface_degree_wizard[subject_raw]"]').native.send_keys(:return)
  end

  def then_i_can_see_the_type_page
    expect(page).to have_content 'What type of bachelor degree is it?'
  end

  def when_i_choose_an_unknown_type_of_degree
    choose 'Another bachelor degree type', visible: false
    fill_in 'Degree type', with: 'Jedi Knight'
    # Triggering the autocomplete
    find('input[name="candidate_interface_degree_wizard[other_type_raw]"]').native.send_keys(:return)
  end

  def then_i_can_see_the_university_page
    expect(page).to have_content 'Which university awarded your degree?'
  end

  def when_i_fill_in_the_university
    fill_in 'candidate_interface_degree_wizard[university_raw]', with: 'University of Cambridge'
    # Triggering the autocomplete
    find('input[name="candidate_interface_degree_wizard[university_raw]"]').native.send_keys(:return)
  end

  def then_i_can_see_the_completion_page
    expect(page).to have_content 'Have you completed your degree?'
  end

  def when_i_choose_whether_degree_is_completed
    choose 'Yes', visible: false
  end

  def then_i_can_see_the_grade_page
    expect(page).to have_content('What grade is your degree?')
  end

  def when_i_select_the_grade
    choose 'First-class honours', visible: false
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

  def then_i_can_check_my_undergraduate_degree
    expect(page).to have_current_path candidate_interface_degree_review_path
    expect(page).to have_content 'History'
  end

  def when_i_mark_this_section_as_completed
    choose t('application_form.completed_radio'), visible: false
  end

  def then_i_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(find_by_id('degree-badge-id').text).to eq('Completed')
  end

  def then_i_can_check_my_answers
    expect(page).to have_content 'United Kingdom'
    expect(page).to have_content 'Bachelor degree'
    expect(page).to have_content 'Jedi Knight'
    expect(page).to have_content 'University of Cambridge'
    expect(page).to have_content 'First-class honours'
    expect(page).to have_content '2006'
    expect(page).to have_content '2009'
  end

  def and_i_click_on_save_changes_and_return
    click_link_or_button t('save_changes_and_return')
  end
end
