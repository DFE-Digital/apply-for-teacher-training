require 'rails_helper'

RSpec.describe 'Candidate tries to submit undergraduate courses with no A levels' do
  include CandidateHelper

  scenario 'when teacher degree apprenticeship is live' do
    given_i_am_on_the_cycle_when_candidates_can_enter_details_for_undergraduate_course
    and_teacher_degree_apprenticeship_feature_flag_is_on
    and_there_is_undergraduate_courses
    and_i_am_signed_in
    when_i_view_the_a_levels_section
    then_i_see_the_content_for_postgraduate_and_undergraduate
    when_i_choose_no_a_levels
    and_i_click_continue
    then_i_am_on_a_levels_review_page
    and_i_see_the_postgraduate_and_undergraduate_content_for_no_a_levels

    when_i_try_to_apply_for_an_undergraduate_course
    then_i_see_that_i_need_a_levels_to_apply_for_an_undergraduate_course
  end

  scenario 'when teacher degree apprenticeship is not live' do
    given_i_am_on_the_cycle_when_candidates_can_not_enter_details_for_undergraduate_course
    and_i_am_signed_in
    when_i_view_the_a_levels_section
    then_i_see_the_content_for_postgraduate

    when_i_choose_no_a_levels
    and_i_click_continue
    then_i_am_on_a_levels_review_page
    and_i_see_the_postgraduate_content_for_no_a_levels
  end

  def given_i_am_on_the_cycle_when_candidates_can_enter_details_for_undergraduate_course
    TestSuiteTimeMachine.travel_permanently_to(
      CycleTimetableHelper.mid_cycle(2025),
    )
  end

  def given_i_am_on_the_cycle_when_candidates_can_not_enter_details_for_undergraduate_course
    TestSuiteTimeMachine.travel_permanently_to(
      CycleTimetableHelper.mid_cycle(2024),
    )
  end

  def and_teacher_degree_apprenticeship_feature_flag_is_on
    FeatureFlag.activate(:teacher_degree_apprenticeship)
  end

  def and_there_is_undergraduate_courses
    create(
      :course,
      :open,
      :secondary,
      :teacher_degree_apprenticeship,
      :with_course_options,
      provider: create(:provider, name: 'Oxford University', code: 'DCBA'),
      name: 'Mathematics',
      code: 'ABCD',
      recruitment_cycle_year: 2025,
    )
  end

  def and_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_view_the_a_levels_section
    visit candidate_interface_details_path
    click_link_or_button 'A levels and other qualifications'
  end

  def then_i_see_the_content_for_postgraduate_and_undergraduate
    expect(no_a_levels_hint).to have_content(
      'A levels are required for teacher degree apprenticeships. If you are applying to postgraduate courses, adding A levels and other qualifications will make your application stronger.',
    )
  end

  def then_i_see_the_content_for_postgraduate
    expect(no_a_levels_hint).to have_content(
      'Providers look at A levels and other qualifications for evidence of subject knowledge not covered in your degree or work history.',
    )
  end

  def when_i_choose_no_a_levels
    choose 'I do not want to add any A levels and other qualifications'
  end

  def and_i_click_continue
    click_link_or_button 'Continue'
  end

  def then_i_am_on_a_levels_review_page
    expect(page).to have_current_path(
      candidate_interface_review_other_qualifications_path,
    )
  end

  def and_i_see_the_postgraduate_and_undergraduate_content_for_no_a_levels
    expect(page).to have_content(
      'A levels are required for teacher degree apprenticeships. If you are applying to postgraduate courses, adding A levels and other qualifications will make your application stronger. They demonstrate subject knowledge not covered in your degree or work history.',
    )
  end

  def and_i_see_the_postgraduate_content_for_no_a_levels
    expect(page).to have_content(
      'Adding A levels and other qualifications makes your application stronger. They demonstrate subject knowledge not covered in your degree or work experience. Training providers usually ask you for them later in the process. Add a qualification',
    )
  end

  def when_i_try_to_apply_for_an_undergraduate_course
    visit candidate_interface_application_choices_path
    click_link_or_button 'Add application'
    choose 'Yes, I know where I want to apply'
    click_link_or_button t('continue')

    select 'Oxford University (DCBA)'
    click_link_or_button t('continue')

    choose 'Mathematics (ABCD)'
    click_link_or_button t('continue')
  end

  def then_i_see_that_i_need_a_levels_to_apply_for_an_undergraduate_course
    expect(page).to have_content(
      'To apply for this course, you need an A level or equivalent qualification. Add your A level grade (or equivalent) and complete the rest of your details. You can then submit your application. Your application will be saved as a draft while you finish adding your details.',
    )
  end

  def no_a_levels_hint
    find_by_id(
      'candidate-interface-other-qualification-type-form-qualification-type-no-other-qualifications-hint',
    ).text
  end
end
