require 'rails_helper'

RSpec.describe 'Editing a degree' do
  include CandidateHelper

  it 'Candidate edits their degree' do
    given_i_am_signed_in_with_one_login
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

    when_i_click_to_change_my_undergraduate_country
    then_i_see_my_chosen_undergraduate_country
    when_i_change_my_undergraduate_country_to_another_country
    and_i_click_on_save_and_continue
    then_i_can_check_my_undergraduate_degree_type_has_been_cleared

    when_i_click_to_change_my_undergraduate_degree_type_again
    and_i_change_my_degree_to_another_masters_degree_type
    and_i_click_on_save_and_continue
    then_i_can_check_my_revised_masters_undergraduate_degree
    when_i_click_to_change_my_masters_undergraduate_degree_type
    then_i_see_another_masters_degree_selected
  end

  def and_i_have_completed_the_degree_section
    @application_form = create(:application_form, candidate: @current_candidate)
    create(:application_qualification,
           level: 'degree',
           qualification_type: 'Bachelor of Arts',
           start_year: '2006',
           award_year: '2009',
           predicted_grade: false,
           subject: 'Computer science',
           institution_name: 'University of Cambridge',
           institution_country: nil,
           grade: 'Aegrotat',
           application_form: @application_form)
    @application_form.update!(degrees_completed: true)
  end

  def when_i_view_the_degree_section
    visit candidate_interface_details_path
    when_i_click_on_degree
  end

  def when_i_click_on_degree
    click_link_or_button 'Degree'
  end

  def and_i_click_on_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def when_i_click_on_continue
    click_link_or_button t('continue')
  end

  def and_i_click_on_continue
    when_i_click_on_continue
  end

  def and_i_click_to_change_my_undergraduate_degree_type
    click_change_link('degree type')
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
  alias_method :and_i_click_to_change_my_undergraduate_degree_subject, :when_i_click_to_change_my_undergraduate_degree_subject

  def when_i_click_to_change_my_undergraduate_degree_institution
    click_change_link('institution')
  end

  def when_i_click_to_change_my_undergraduate_country
    click_change_link('country')
  end

  def then_i_see_my_chosen_undergraduate_degree_type
    expect(page.find_field('Bachelor degree')).to be_checked
  end

  def then_i_see_my_undergraduate_degree_start_year_filled_in
    expect(page).to have_css("input[name='candidate_interface_degree_wizard[start_year]'][value='2006']")
  end

  def then_i_see_my_undergraduate_degree_award_year_filled_in
    expect(page).to have_css("input[name='candidate_interface_degree_wizard[award_year]'][value='2009']")
  end

  def then_i_see_my_undergraduate_degree_subject_filled_in
    expect(selected_option_for_field('What subject is your degree?')).to eq('Computer science')
  end

  def selected_option_for_field(field_name)
    page.find_field(field_name).all('option').find { |element| element[:selected] }.try(:text)
  end

  def then_i_see_my_undergraduate_degree_institution_filled_in
    expect(selected_option_for_field('candidate_interface_degree_wizard[university]')).to eq('University of Cambridge')
  end

  def then_i_see_my_undergraduate_degree_grade_filled_in
    expect(page.find_field('Other')).to be_checked
    expect(page.find_field('Enter your degree grade').value).to eq('Aegrotat')
  end

  def then_i_see_my_chosen_undergraduate_country
    expect(page.find_field('United Kingdom')).to be_checked
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
    select 'Computer games', from: 'candidate_interface_degree_wizard[subject]'
  end

  def when_i_change_my_undergraduate_degree_institution
    select 'University of Oxford', from: 'candidate_interface_degree_wizard[university]'
  end

  def when_i_change_my_undergraduate_degree_grade
    choose 'Merit'
  end

  def when_i_change_my_undergraduate_country_to_another_country
    choose 'Another country'
    select 'France'
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
    expect(page).to have_content 'Computer games'
  end

  def then_i_can_check_my_revised_undergraduate_degree_institution
    expect(page).to have_content 'University of Oxford'
  end

  def then_i_can_check_my_revised_undergraduate_degree_grade
    expect(page).to have_content 'Merit'
  end

  def then_i_can_check_my_revised_completion_status_and_award_year
    completion_status_row = page.all('.govuk-summary-list__row').find { |row| row.has_link? 'Change completion status' }
    expect(completion_status_row).to have_content 'No'

    expect(page).to have_content RecruitmentCycle.current_year.to_s
  end

  def then_i_can_check_my_undergraduate_degree_type_has_been_cleared
    expect(page).to have_content('What type of degree is it?')
    expect(page.find_field('candidate-interface-degree-wizard-international-type-field').value).to be_nil
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
    click_change_link('degree type')
    choose 'Level 6 Diploma'
    and_i_click_on_save_and_continue
  end

  def then_i_can_check_my_revised_undergraduate_degree_type_again
    expect(page).to have_content 'Level 6 Diploma'
    expect(page).to have_no_content 'Master of Arts'
    expect(page).to have_no_content 'MA'
  end

  def when_i_click_to_change_my_undergraduate_degree_type_again
    visit candidate_interface_degree_review_path
    click_change_link('degree type')
  end

  def and_i_change_my_degree_to_another_masters_degree_type
    choose 'Master’s degree'
    and_i_click_on_save_and_continue
    choose 'Another master’s degree type'
    select 'Master of Business Administration'
  end

  def then_i_can_check_my_revised_masters_undergraduate_degree
    expect(page).to have_content 'Master of Business Administration'
  end

  def when_i_click_to_change_my_masters_undergraduate_degree_type
    click_change_link('specific type of degree')
  end

  def then_i_see_another_masters_degree_selected
    expect(page.find_field('Another master’s degree type')).to be_checked
  end
end
