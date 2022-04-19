require 'rails_helper'

RSpec.feature 'Entering a degree', js: true do
  include CandidateHelper

  before do
    FeatureFlag.deactivate(:new_degree_flow)
  end

  scenario 'Candidate enters their degree' do
    given_i_am_signed_in
    when_i_view_the_degree_section

    # Add degree type
    and_i_choose_uk_degree
    and_i_click_on_save_and_continue
    then_i_see_validation_errors_for_degree_type
    when_i_fill_in_the_degree_type
    and_i_click_on_save_and_continue

    # Add subject
    then_i_can_see_the_degree_subject_page
    when_i_click_on_save_and_continue
    then_i_see_validation_errors_for_degree_subject
    when_i_fill_in_the_degree_subject
    and_i_click_on_save_and_continue

    # Add institution
    then_i_can_see_the_degree_institution_page
    when_i_click_on_save_and_continue
    then_i_see_validation_errors_for_degree_institution
    when_i_fill_in_the_degree_institution
    and_i_click_on_save_and_continue

    # Add completion status
    and_i_confirm_i_have_completed_my_degree

    # Add grade
    then_i_can_see_the_degree_grade_page
    when_i_click_on_save_and_continue
    then_i_see_validation_errors_for_degree_grade
    when_i_select_the_degree_grade
    and_i_click_on_save_and_continue

    # Add start year
    then_i_can_see_the_start_year_page
    when_i_click_on_save_and_continue
    then_i_see_validation_errors_for_start_year
    when_i_fill_in_the_start_year
    and_i_click_on_save_and_continue

    # Add award year
    then_i_can_see_the_award_year_page
    when_i_click_on_save_and_continue
    then_i_see_validation_errors_for_award_year
    when_i_fill_in_the_award_year
    and_i_click_on_save_and_continue

    # Review
    then_i_can_check_my_undergraduate_degree

    # Mark section as complete
    when_i_click_on_continue
    then_i_see_a_section_complete_error

    when_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_i_should_see_the_form
    and_that_the_section_is_completed

    when_i_click_on_degree
    then_i_can_check_my_answers
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_view_the_degree_section
    visit candidate_interface_application_form_path
    when_i_click_on_degree
  end

  def when_i_click_on_degree
    click_link 'Degree'
  end

  def then_i_see_the_undergraduate_degree_form
    expect(page).to have_content 'Add undergraduate degree'
  end

  def and_i_choose_uk_degree
    choose 'UK degree', visible: false
  end

  def and_i_click_on_save_and_continue
    click_button t('save_and_continue')
  end

  def when_i_click_on_save_and_continue
    click_button t('save_and_continue')
  end

  def then_i_see_validation_errors_for_degree_type
    expect_validation_error 'Enter your degree type'
  end

  def when_i_fill_in_the_degree_type
    fill_in 'Type of degree', with: 'Bachelor of Science'

    # Triggering the autocomplete
    find('input[name="candidate_interface_degree_type_form[type_description_raw]"]').native.send_keys(:return)
  end
  alias_method :and_i_fill_in_the_degree_type, :when_i_fill_in_the_degree_type

  def then_i_can_see_the_degree_subject_page
    expect(page).to have_content 'What subject is your degree?'
  end

  def then_i_see_validation_errors_for_degree_subject
    expect_validation_error 'Enter your degree subject'
  end

  def when_i_fill_in_the_degree_subject
    fill_in 'What subject is your degree?', with: 'Computer science'
    # Triggering the autocomplete
    find('input[name="candidate_interface_degree_subject_form[subject_raw]"]').native.send_keys(:return)
  end

  def then_i_can_see_the_degree_institution_page
    expect(page).to have_content 'Which institution did you study at?'
  end

  def then_i_see_validation_errors_for_degree_institution
    expect_validation_error 'Enter the institution where you studied'
  end

  def when_i_fill_in_the_degree_institution
    fill_in 'Which institution did you study at?', with: 'The Open University'
    # Triggering the autocomplete
    find('input[name="candidate_interface_degree_institution_form[institution_name_raw]').native.send_keys(:return)
  end

  def then_i_can_see_the_degree_grade_page
    expect(page).to have_content('What grade is your degree?')
  end

  def then_i_see_validation_errors_for_degree_grade
    expect_validation_error 'Enter your degree grade'
  end

  def when_i_select_the_degree_grade
    choose 'First-class honours', visible: false
  end

  def then_i_can_see_the_start_year_page
    expect(page).to have_content('What year did you start your degree?')
  end

  def then_i_see_validation_errors_for_start_year
    expect_validation_error 'Enter your start year'
  end

  def when_i_fill_in_the_start_year
    year_with_trailing_space = '2006 '
    fill_in t('page_titles.what_year_did_you_start_your_degree'), with: year_with_trailing_space
  end

  def then_i_can_see_the_award_year_page
    expect(page).to have_content('What year did you graduate?')
  end

  def then_i_see_validation_errors_for_award_year
    expect_validation_error 'Enter your graduation year'
  end

  def when_i_fill_in_the_award_year
    year_with_preceding_space = ' 2009'
    fill_in t('page_titles.what_year_did_you_graduate'), with: year_with_preceding_space
  end

  def then_i_can_check_my_undergraduate_degree
    expect(page).to have_current_path candidate_interface_degrees_review_path
    expect(page).to have_content 'Computer science'
  end

  def when_i_click_on_continue
    click_button t('continue')
  end

  def and_i_click_on_continue
    when_i_click_on_continue
  end

  def when_i_mark_this_section_as_completed
    choose t('application_form.completed_radio'), visible: false
  end

  def and_i_click_on_continue
    when_i_click_on_continue
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(page.find('#degree-badge-id').text).to eq('COMPLETED')
  end

  def then_i_can_check_my_answers
    expect(page).to have_content 'BSc (Hons)'
  end

  def and_i_confirm_i_have_completed_my_degree
    choose 'Yes', visible: false
    and_i_click_on_save_and_continue
  end

  def then_i_see_a_section_complete_error
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/section_complete_form.attributes.completed.blank')
  end

  def when_i_click_to_change_my_completion_status
    click_change_link('completion status')
  end

  def then_i_can_change_my_completion_status
    expect(page).to have_content 'Have you completed your degree?'
    choose 'No', visible: false
    and_i_click_on_save_and_continue
    completion_status_row = page.all('.govuk-summary-list__row').find { |r| r.has_link? 'Change completion status' }
    expect(completion_status_row).to have_content 'No'
  end
end
