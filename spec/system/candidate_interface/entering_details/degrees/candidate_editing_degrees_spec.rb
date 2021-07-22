require 'rails_helper'

RSpec.feature 'Editing a degree' do
  include CandidateHelper

  scenario 'Candidate edits their degree' do
    given_i_am_signed_in
    and_i_have_completed_the_degree_section
    when_i_view_the_degree_section
    and_i_click_to_change_my_undergraduate_degree_type
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

    when_i_click_to_change_my_completion_status
    then_i_can_change_my_completion_status

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
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_completed_the_degree_section
    @application_form = create(:application_form, candidate: @candidate)
    create(:application_qualification,
           level: 'degree',
           qualification_type: 'BSc',
           start_year: '2006',
           award_year: '2009',
           predicted_grade: false,
           subject: 'Computer Science',
           institution_name: 'MIT',
           application_form: @application_form)
    @application_form.update!(degrees_completed: true)
  end

  def when_i_view_the_degree_section
    visit candidate_interface_application_form_path
    when_i_click_on_degree
  end

  def when_i_click_on_degree
    click_link 'Degree'
  end

  def then_i_can_check_my_undergraduate_degree
    expect(page).to have_current_path candidate_interface_degrees_review_path
  end

  def and_i_click_on_save_and_continue
    click_button t('save_and_continue')
  end

  def when_i_click_on_continue
    click_button t('continue')
  end

  def and_i_click_on_continue
    when_i_click_on_continue
  end

  def and_i_click_to_change_my_undergraduate_degree_type
    click_change_link('qualification')
  end

  def when_i_click_to_change_my_undergraduate_degree_year
    start_year_row = find('.govuk-summary-list__row', text: 'Start year')
    within start_year_row do
      click_change_link('year')
    end
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

  def and_i_click_on_continue
    when_i_click_on_continue
  end

  def when_i_click_to_change_my_completion_status
    click_change_link('completion status')
  end

  def then_i_can_change_my_completion_status
    expect(page).to have_content 'Have you completed your degree?'
    choose 'No'
    and_i_click_on_save_and_continue
    completion_status_row = page.all('.govuk-summary-list__row').find { |r| r.has_link? 'Change completion status' }
    expect(completion_status_row).to have_content 'No'
  end
end
