require 'rails_helper'

RSpec.describe 'Entering a degree' do
  include CandidateHelper

  before do
    given_i_am_on_the_cycle_when_candidates_can_enter_details_for_undergraduate_course
    and_teacher_degree_apprenticeship_feature_flag_is_active
  end

  scenario 'Candidate does not have a degree' do
    given_i_am_signed_in
    when_i_view_the_degree_section
    then_i_can_see_the_university_degree_page

    when_i_click_continue
    then_i_see_the_error_message_to_answer_the_degree_question

    when_i_answer_no
    and_i_click_continue
    then_i_can_see_degrees_section_is_completed

    # test that clicking on review degrees section
    # doesn't change the section to incomplete
    when_i_click_degree_section
    and_i_click_back
    then_i_can_see_degrees_section_is_completed

    when_i_click_degree_section
    then_i_do_not_see_the_button_to_add_a_degree
    and_i_am_on_the_degree_review_page
    and_i_see_that_i_do_not_have_a_degree

    when_i_click_to_change
    then_i_can_see_the_university_degree_page
    and_i_see_the_no_degree_option_chosen
  end

  scenario 'Candidate does have a university degree' do
    given_i_am_signed_in
    when_i_view_the_degree_section
    then_i_can_see_the_university_degree_page

    when_i_answer_yes
    and_i_click_continue
    then_i_can_see_the_country_page
    and_the_back_link_points_to_the_university_degree_page
  end

  def given_i_am_on_the_cycle_when_candidates_can_enter_details_for_undergraduate_course
    TestSuiteTimeMachine.advance_time_to(
      CycleTimetableHelper.after_apply_deadline(2024),
    )
  end

  def and_teacher_degree_apprenticeship_feature_flag_is_active
    FeatureFlag.activate(:teacher_degree_apprenticeship)
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_view_the_degree_section
    visit candidate_interface_continuous_applications_details_path
    when_i_click_on_degree
  end

  def when_i_click_on_degree
    click_link_or_button 'Degree'
  end

  def then_i_can_see_the_university_degree_page
    expect(page).to have_current_path(candidate_interface_degree_university_degree_path)
    expect(page).to have_content('Do you have a university degree?')
  end

  def when_i_answer_no
    choose 'No, I do not have a degree'
  end

  def when_i_answer_yes
    choose 'Yes, I have a degree or am studying for one'
  end

  def then_i_can_see_degrees_section_is_completed
    expect(page).to have_current_path(candidate_interface_continuous_applications_details_path)
    expect(page).to have_content('Degree Completed')
  end

  def then_i_can_see_the_country_page
    expect(page).to have_content('Which country was the degree from?')
  end

  def and_the_back_link_points_to_the_university_degree_page
    expect(back_link).to eq(candidate_interface_degree_university_degree_path)
  end

  def and_i_click_continue
    click_link_or_button 'Continue'
  end
  alias_method :when_i_click_continue, :and_i_click_continue

  def when_i_click_degree_section
    click_link_or_button 'Degree'
  end

  def and_i_click_back
    click_link_or_button 'Back'
  end

  def then_i_do_not_see_the_button_to_add_a_degree
    expect(page).to have_no_content('Add a degree')
  end

  def and_i_am_on_the_degree_review_page
    expect(page).to have_current_path(candidate_interface_degree_review_path)
  end

  def when_i_click_to_change
    click_link_or_button 'Change'
  end

  def and_i_see_that_i_do_not_have_a_degree
    expect(page).to have_content('Do you have a university degree? No, I do not have a degree Change')
  end

  def and_i_see_the_no_degree_option_chosen
    expect(find_field('No, I do not have a degree').checked?).to be true
  end

  def then_i_see_the_error_message_to_answer_the_degree_question
    expect(page).to have_content('Select whether you have a university degree')
  end

  def back_link
    find('a', text: 'Back')[:href]
  end
end
