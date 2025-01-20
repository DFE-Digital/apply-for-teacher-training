require 'rails_helper'

RSpec.describe 'Submitting a postgraduate course' do
  include CandidateHelper

  before do
    given_i_am_on_the_cycle_when_candidates_can_enter_details_for_undergraduate_course
    given_i_am_signed_in_with_one_login
  end

  scenario 'Candidate does not have a degree' do
    given_there_are_postgraduate_courses
    and_i_have_all_sections_completed_except_degrees
    when_i_view_the_degree_section
    when_i_answer_no
    and_i_click_continue
    then_i_can_see_degrees_section_is_completed

    when_i_click_degree_section
    then_i_see_that_i_do_not_have_a_degree

    when_i_try_to_apply_for_an_postgraduate_course
    then_i_see_that_i_need_degrees_to_apply_for_an_postgraduate_course
  end

  def given_i_am_on_the_cycle_when_candidates_can_enter_details_for_undergraduate_course
    TestSuiteTimeMachine.travel_permanently_to(
      CycleTimetableHelper.mid_cycle(2025),
    )
  end

  def given_there_are_postgraduate_courses
    create(
      :course,
      :open,
      :secondary,
      :with_course_options,
      provider: create(:provider, name: 'Oxford University', code: 'DCBA'),
      name: 'Mathematics',
      code: 'ABCD',
      recruitment_cycle_year: 2025,
    )
  end

  def and_i_have_all_sections_completed_except_degrees
    @current_candidate.application_forms << create(
      :application_form,
      :completed,
      degrees_completed: false,
      application_qualifications: [],
    )
  end

  def when_i_view_the_degree_section
    visit candidate_interface_details_path
    when_i_click_on_degree
  end

  def when_i_click_on_degree
    click_link_or_button 'Degree'
  end

  def when_i_answer_no
    choose 'No, I do not have a degree'
  end

  def when_i_answer_yes
    choose 'Yes, I have a degree or am studying for one'
  end

  def then_i_can_see_degrees_section_is_completed
    expect(page).to have_current_path(candidate_interface_details_path)
    expect(page).to have_content('Degree Completed')
  end

  def and_i_click_continue
    click_link_or_button 'Continue'
  end
  alias_method :when_i_click_continue, :and_i_click_continue

  def when_i_click_degree_section
    click_link_or_button 'Degree'
  end

  def and_i_click_save_and_continue
    click_link_or_button 'Save and continue'
  end

  def then_i_see_that_i_do_not_have_a_degree
    expect(page).to have_content('Do you have a university degree? No, I do not have a degree Change')
  end

  def when_i_try_to_apply_for_an_postgraduate_course
    visit candidate_interface_application_choices_path
    click_link_or_button 'Add application'
    choose 'Yes, I know where I want to apply'
    click_link_or_button t('continue')

    select 'Oxford University (DCBA)'
    click_link_or_button t('continue')

    choose 'Mathematics (ABCD)'
    click_link_or_button t('continue')
  end

  def then_i_see_that_i_need_degrees_to_apply_for_an_postgraduate_course
    expect(page).to have_content(
      'To apply for this course, you need a bachelor’s degree or equivalent qualification. Add your degree (or equivalent) and complete the rest of your details. You can then submit your application. Your application will be saved as a draft while you finish adding your details.',
    )
  end
end
