require 'rails_helper'

RSpec.feature 'Entering their degrees' do
  include CandidateHelper

  scenario 'Candidate submits their degrees' do
    FeatureFlag.deactivate(:international_degrees)

    given_i_am_signed_in
    and_i_visit_the_site
    when_i_click_on_degree
    then_i_see_the_undergraduate_degree_form

    # Add degree type
    when_i_click_on_save_and_continue
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

    # Add grade
    then_i_can_see_the_degree_grade_page
    when_i_click_on_save_and_continue
    then_i_see_validation_errors_for_degree_grade
    when_i_select_the_degree_grade
    and_i_click_on_save_and_continue

    # Add years
    then_i_can_see_the_start_and_graduation_year_page
    when_i_click_on_save_and_continue
    then_i_see_validation_errors_for_graduation_year
    when_i_fill_in_the_start_and_graduation_year
    and_i_click_on_save_and_continue

    # Review
    then_i_can_check_my_undergraduate_degree

    # Delete and replace
    when_i_click_on_delete_degree
    and_i_confirm_that_i_want_to_delete_my_degree
    then_i_see_the_undergraduate_degree_form

    when_i_add_my_degree_back_in
    and_i_click_on_continue
    then_i_should_see_the_form_and_the_section_is_not_completed
    when_i_click_on_degree
    then_i_can_check_my_undergraduate_degree

    when_i_click_on_add_another_degree
    then_i_see_the_add_another_degree_form
    when_i_fill_in_my_additional_degree
    then_i_can_check_my_additional_degree

    when_i_click_on_delete_degree
    and_i_confirm_that_i_want_to_delete_my_additional_degree
    then_i_can_only_see_my_undergraduate_degree

    # Edit details
    when_i_click_to_change_my_undergraduate_degree_type
    then_i_see_my_undergraduate_degree_type_filled_in
    when_i_change_my_undergraduate_degree_type
    and_i_click_on_save_and_continue
    then_i_can_check_my_revised_undergraduate_degree_type

    when_i_click_to_change_my_undergraduate_degree_year
    then_i_see_my_undergraduate_degree_year_filled_in
    when_i_change_my_undergraduate_degree_year
    and_i_click_on_save_and_continue
    then_i_can_check_my_revised_undergraduate_degree_year

    when_i_click_to_change_my_undergraduate_degree_subject
    then_i_see_my_undergraduate_degree_subject_filled_in
    when_i_change_my_undergraduate_degree_subject
    and_i_click_on_save_and_continue
    then_i_can_check_my_revised_undergraduate_degree_subject

    when_i_click_to_change_my_undergraduate_degree_institution
    then_i_see_my_undergraduate_degree_institution_filled_in
    when_i_change_my_undergraduate_degree_institution
    and_i_click_on_save_and_continue
    then_i_can_check_my_revised_undergraduate_degree_institution

    when_i_click_to_change_my_undergraduate_degree_grade
    then_i_see_my_undergraduate_degree_grade_filled_in
    when_i_change_my_undergraduate_degree_grade
    and_i_click_on_save_and_continue
    then_i_can_check_my_revised_undergraduate_degree_grade

    # Mark section as complete
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

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_degree
    click_link 'Degree'
  end

  def then_i_see_the_undergraduate_degree_form
    expect(page).to have_content 'Add undergraduate degree'
  end

  def and_i_click_on_save_and_continue
    click_button t('application_form.degree.base.button')
  end

  def when_i_click_on_save_and_continue
    click_button t('application_form.degree.base.button')
  end

  def then_i_see_validation_errors_for_degree_type
    expect(page).to have_content 'Enter your degree type'
  end

  def when_i_fill_in_the_degree_type
    fill_in 'Type of degree', with: 'BSc'
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

  def then_i_see_validation_errors_for_degree_institution
    expect(page).to have_content 'Enter the institution where you studied'
  end

  def when_i_fill_in_the_degree_institution
    fill_in 'Which institution did you study at?', with: 'MIT'
  end

  def then_i_can_see_the_degree_grade_page
    expect(page).to have_content('What grade is your degree?')
  end

  def then_i_see_validation_errors_for_degree_grade
    expect(page).to have_content 'Enter your degree grade'
  end

  def when_i_select_the_degree_grade
    choose 'First class honours'
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

  def when_i_click_on_continue
    click_button t('application_form.degree.review.button')
  end

  def and_i_click_on_continue
    when_i_click_on_continue
  end

  def then_i_should_see_the_form_and_the_section_is_not_completed
    expect(page).to have_content(t('page_titles.application_form'))
    expect(page).not_to have_css('#degree-badge-id', text: 'Completed')
  end

  def when_i_click_on_add_another_degree
    click_link t('application_form.degree.another.button')
  end

  def then_i_see_the_add_another_degree_form
    expect(page).to have_content(t('page_titles.add_another_degree'))
  end

  def when_i_add_my_degree_back_in
    when_i_fill_in_the_degree_type
    and_i_click_on_save_and_continue

    when_i_fill_in_the_degree_subject
    and_i_click_on_save_and_continue

    when_i_fill_in_the_degree_institution
    and_i_click_on_save_and_continue

    when_i_select_the_degree_grade
    and_i_click_on_save_and_continue

    when_i_fill_in_the_start_and_graduation_year
    and_i_click_on_save_and_continue
  end

  def when_i_fill_in_my_additional_degree
    fill_in 'Type of degree', with: 'Masters'
    and_i_click_on_save_and_continue
    fill_in 'What subject is your degree?', with: 'Maths'
    and_i_click_on_save_and_continue
    fill_in 'Which institution did you study at?', with: 'Thames Valley University'
    and_i_click_on_save_and_continue
    when_i_select_the_degree_grade
    and_i_click_on_save_and_continue
    when_i_fill_in_the_start_and_graduation_year
    and_i_click_on_save_and_continue
  end

  def and_i_submit_the_add_another_degree_form
    click_button t('application_form.degree.base.button')
  end

  def then_i_can_check_my_additional_degree
    expect(page).to have_content 'Masters (Hons) Maths'
  end

  def when_i_click_on_delete_degree
    click_link(t('application_form.degree.delete'), match: :first)
  end

  def and_i_confirm_that_i_want_to_delete_my_additional_degree
    click_button t('application_form.degree.confirm_delete')
  end

  def and_i_confirm_that_i_want_to_delete_my_degree
    and_i_confirm_that_i_want_to_delete_my_additional_degree
  end

  def then_i_can_only_see_my_undergraduate_degree
    then_i_can_check_my_undergraduate_degree
    expect(page).not_to have_content 'Masters Maths'
  end

  def when_i_click_to_change_my_undergraduate_degree_type
    click_change_link('qualification')
  end

  def when_i_click_to_change_my_undergraduate_degree_year
    click_change_link('year')
  end

  def when_i_click_to_change_my_undergraduate_degree_grade
    click_change_link('grade')
  end

  def when_i_click_to_change_my_undergraduate_degree_subject
    click_change_link('subject')
  end

  def when_i_click_to_change_my_undergraduate_degree_institution
    click_change_link('institution')
  end

  def then_i_see_my_undergraduate_degree_type_filled_in
    expect(page).to have_selector("input[value='BSc']")
  end

  def then_i_see_my_undergraduate_degree_year_filled_in
    expect(page).to have_selector("input[name='candidate_interface_degree_year_form[start_year]'][value='2006']")
    expect(page).to have_selector("input[name='candidate_interface_degree_year_form[award_year]'][value='2009']")
  end

  def then_i_see_my_undergraduate_degree_subject_filled_in
    expect(page).to have_selector("input[value='Computer Science']")
  end

  def then_i_see_my_undergraduate_degree_institution_filled_in
    expect(page).to have_selector("input[value='MIT']")
  end

  def then_i_see_my_undergraduate_degree_grade_filled_in
    expect(page).to have_selector("input[value='First class honours']")
  end

  def when_i_change_my_undergraduate_degree_type
    fill_in 'Type of degree', with: 'BA'
  end

  def when_i_change_my_undergraduate_degree_year
    fill_in 'Year started course', with: '2008'
    fill_in 'Graduation year', with: '2011'
  end

  def when_i_change_my_undergraduate_degree_subject
    fill_in 'What subject is your degree?', with: 'Computer Science and AI'
  end

  def when_i_change_my_undergraduate_degree_institution
    fill_in 'Which institution did you study at?', with: 'Stanford'
  end

  def when_i_change_my_undergraduate_degree_grade
    choose 'Lower second-class honours'
  end

  def then_i_can_check_my_revised_undergraduate_degree_type
    expect(page).to have_content 'BA'
  end

  def then_i_can_check_my_revised_undergraduate_degree_year
    expect(page).to have_content '2008'
    expect(page).to have_content '2011'
  end

  def then_i_can_check_my_revised_undergraduate_degree_subject
    expect(page).to have_content 'Computer Science and AI'
  end

  def then_i_can_check_my_revised_undergraduate_degree_institution
    expect(page).to have_content 'Computer Science and AI'
  end

  def then_i_can_check_my_revised_undergraduate_degree_grade
    expect(page).to have_content 'Lower second-class honours'
  end

  def when_i_mark_this_section_as_completed
    check t('application_form.degree.review.completed_checkbox')
  end

  def and_i_click_on_continue
    when_i_click_on_continue
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#degree-badge-id', text: 'Completed')
  end

  def then_i_can_check_my_answers
    then_i_can_check_my_revised_undergraduate_degree_type
  end

  def then_i_am_told_i_need_to_add_a_degree_to_complete_the_section
    expect(page).to have_content 'You cannot mark this section complete without adding a degree.'
  end

private

  def click_change_link(row_description)
    link_text = "Change #{row_description}"
    page.all('.govuk-summary-list__actions')
      .find { |row| row.has_link?(link_text) }
      .click_link(link_text)
  end
end
