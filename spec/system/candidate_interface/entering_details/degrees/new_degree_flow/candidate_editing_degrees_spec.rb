require 'rails_helper'

RSpec.feature 'Editing a degree' do
  include CandidateHelper

  before do
    FeatureFlag.activate(:new_degree_flow)
    allow(CycleTimetable).to receive(:current_year).and_return(2022)
  end

  scenario 'Candidate edits their degree' do
    given_i_am_signed_in
    and_i_have_completed_the_degree_section
    when_i_view_the_degree_section
    and_i_click_to_change_my_undergraduate_degree_type
    then_i_see_my_chosen_undergraduate_degree_type

    when_i_change_my_undergraduate_degree_type
    and_i_click_on_save_and_continue
    and_i_choose_my_specific_undergraduate_degree_type
    and_i_click_on_save_and_continue
    then_i_can_check_my_revised_undergraduate_degree_type

    when_i_click_to_change_my_undergraduate_degree_start_year
    then_i_see_my_undergraduate_degree_start_year_filled_in
    when_i_change_my_undergraduate_degree_start_year
    and_i_click_on_save_and_continue
    then_i_can_check_my_revised_undergraduate_degree_start_year

    when_i_click_to_change_my_undergraduate_degree_award_year
    then_i_see_my_undergraduate_degree_award_year_filled_in
    when_i_change_my_undergraduate_degree_award_year
    and_i_click_on_save_and_continue
    then_i_can_check_my_revised_undergraduate_degree_award_year

    when_i_click_to_change_my_undergraduate_degree_subject
    then_i_see_my_undergraduate_degree_subject_filled_in
    when_i_change_my_undergraduate_degree_subject
    and_i_click_on_save_and_continue
    then_i_can_check_my_revised_undergraduate_degree_subject

    when_i_click_to_change_my_completion_status
    then_i_can_change_my_completion_status
    and_i_click_on_save_and_continue
    when_i_change_my_undergraduate_degree_award_year_again
    and_i_click_on_save_and_continue
    then_i_can_check_my_revised_completion_status_and_award_year

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

    when_i_change_my_undergraduate_degree_type_to_a_diploma
    then_i_can_check_my_revised_undergraduate_degree_type_again
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_completed_the_degree_section
    @application_form = create(:application_form, candidate: @candidate)
    create(:application_qualification,
           level: 'degree',
           qualification_type: 'Bachelor of Arts',
           start_year: '2006',
           award_year: '2009',
           predicted_grade: false,
           subject: 'Computer Science',
           institution_name: 'MIT',
           grade: 'A',
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

  def when_i_click_to_change_my_undergraduate_degree_start_year
    click_change_link('start year')
  end

  def when_i_click_to_change_my_undergraduate_degree_award_year
    click_change_link('graduation year')
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

  def then_i_see_my_chosen_undergraduate_degree_type
    expect(page.find_field('Bachelor degree')).to be_checked
  end

  def then_i_see_my_undergraduate_degree_start_year_filled_in
    expect(page).to have_selector("input[name='candidate_interface_degree_wizard[start_year]'][value='2006']")
  end

  def then_i_see_my_undergraduate_degree_award_year_filled_in
    expect(page).to have_selector("input[name='candidate_interface_degree_wizard[award_year]'][value='2009']")
  end

  def then_i_see_my_undergraduate_degree_subject_filled_in
    expect(page).to have_selector("input[value='Computer Science']")
  end

  def then_i_see_my_undergraduate_degree_institution_filled_in
    expect(page).to have_selector("input[value='MIT']")
  end

  def then_i_see_my_undergraduate_degree_grade_filled_in
    expect(page.find_field('Other')).to be_checked
    expect(page.find_field('Enter your degree grade').value).to eq('A')
  end

  def when_i_change_my_undergraduate_degree_type
    choose 'Master’s degree'
  end

  def when_i_change_my_undergraduate_degree_start_year
    fill_in t('page_titles.what_year_did_you_start_your_degree'), with: '2008'
  end

  def when_i_change_my_undergraduate_degree_award_year
    fill_in t('page_titles.what_year_did_you_graduate'), with: '2011'
  end

  def when_i_change_my_undergraduate_degree_award_year_again
    graduation_year = RecruitmentCycle.current_year.to_s
    fill_in t('page_titles.what_year_will_you_graduate'), with: graduation_year
  end

  def when_i_change_my_undergraduate_degree_subject
    fill_in 'candidate-interface-degree-wizard-subject-field', with: 'Computer Science and AI'
  end

  def when_i_change_my_undergraduate_degree_institution
    fill_in 'candidate-interface-degree-wizard-university-field', with: 'Stanford'
  end

  def when_i_change_my_undergraduate_degree_grade
    choose 'Lower second-class honours (2:2)'
  end

  def then_i_can_check_my_revised_undergraduate_degree_type
    expect(page).to have_content 'Master of Arts'
    expect(page).to have_content 'MA'
  end

  def and_i_choose_my_specific_undergraduate_degree_type
    choose 'Master of Arts (MA)'
  end

  def then_i_can_check_my_revised_undergraduate_degree_start_year
    expect(page).to have_content '2008'
  end

  def then_i_can_check_my_revised_undergraduate_degree_award_year
    expect(page).to have_content '2011'
  end

  def then_i_can_check_my_revised_undergraduate_degree_subject
    expect(page).to have_content 'Computer Science and AI'
  end

  def then_i_can_check_my_revised_undergraduate_degree_institution
    expect(page).to have_content 'Computer Science and AI'
  end

  def then_i_can_check_my_revised_undergraduate_degree_grade
    expect(page).to have_content 'Lower second-class honours (2:2)'
  end

  def then_i_can_check_my_revised_completion_status_and_award_year
    completion_status_row = page.all('.govuk-summary-list__row').find { |r| r.has_link? 'Change completion status' }
    expect(completion_status_row).to have_content 'No'

    expect(page).to have_content RecruitmentCycle.current_year.to_s
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
  end

  def when_i_change_my_undergraduate_degree_type_to_a_diploma
    click_change_link('qualification')
    choose 'Level 6 Diploma'
    and_i_click_on_save_and_continue
  end

  def then_i_can_check_my_revised_undergraduate_degree_type_again
    expect(page).to have_content 'Level 6 Diploma'
    expect(page).not_to have_content 'Master of Arts'
    expect(page).not_to have_content 'MA'
  end
end
