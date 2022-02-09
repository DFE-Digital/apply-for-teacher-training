require 'rails_helper'

RSpec.feature 'Candidate edits their choice section' do
  include CandidateHelper

  scenario 'Candidate deletes and adds additional courses' do
    given_i_am_signed_in
    and_the_apply_again_with_three_choices_feature_flag_is_deactivated
    and_i_have_completed_the_course_choice_section

    when_i_visit_the_course_choices_page
    and_i_click_delete_a_choice
    and_i_confirm_i_want_to_delete_the_choice
    and_visit_my_application_page
    then_the_course_choices_section_should_be_marked_as_incomplete

    given_there_are_courses_to_add
    and_i_have_added_a_course_and_complete_the_course_choices_section

    when_i_visit_the_course_choices_page
    and_i_click_on_add_course
    and_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider
    and_i_choose_a_course_with_a_single_site

    when_i_choose_not_to_add_another_course
    and_i_click_continue
    then_i_should_see_the_course_choices_review_page

    when_i_click_continue
    then_i_should_see_a_section_complete_error

    when_i_mark_the_section_as_complete
    and_i_click_continue
    then_the_course_choices_section_should_be_marked_as_complete
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_the_apply_again_with_three_choices_feature_flag_is_deactivated
    FeatureFlag.deactivate(:apply_again_with_three_choices)
  end

  def and_i_have_completed_the_course_choice_section
    @application_form = create(:application_form, candidate: @candidate, course_choices_completed: true)
    create(:application_choice, application_form: @application_form, status: :unsubmitted)
  end

  def when_i_visit_the_course_choices_page
    visit candidate_interface_course_choices_review_path
  end

  def and_i_click_delete_a_choice
    click_link 'Delete choice'
  end

  def and_i_confirm_i_want_to_delete_the_choice
    click_button t('application_form.courses.confirm_delete')
  end

  def and_visit_my_application_page
    visit candidate_interface_application_form_path
  end

  def then_the_course_choices_section_should_be_marked_as_incomplete
    expect(page.text).to include 'Choose your courses Incomplete'
  end

  def then_the_course_choices_section_should_be_marked_as_complete
    expect(page.text).to include 'Choose your courses Complete'
  end

  def given_there_are_courses_to_add
    @course = create(:course, exposed_in_find: true, open_on_apply: true)
    @course_option = create(:course_option, course: @course)
  end

  def and_i_have_added_a_course_and_complete_the_course_choices_section
    @application_choice = create(:application_choice, application_form: @application_form, status: :unsubmitted)
    @application_form.update!(course_choices_completed: true)
  end

  def and_i_click_on_add_course
    click_link 'Add another course'
  end

  def and_i_choose_that_i_know_where_i_want_to_apply
    choose 'Yes, I know where I want to apply'
    click_button t('continue')
  end

  def and_i_choose_a_provider
    select @course.provider.name_and_code
    click_button t('continue')
  end

  def and_i_choose_a_course_with_a_single_site
    choose @course.name_and_code
    click_button t('continue')
  end

  def and_i_click_continue
    click_button t('continue')
  end

  def when_i_click_continue
    and_i_click_continue
  end

  def then_i_should_see_a_section_complete_error
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/section_complete_form.attributes.completed.blank')
  end

  def when_i_choose_not_to_add_another_course
    choose 'No, not at the moment'
  end

  def when_i_mark_the_section_as_complete
    choose t('application_form.completed_radio')
  end

  def then_i_should_see_the_course_choices_review_page
    expect(page).to have_current_path(candidate_interface_course_choices_review_path)
  end
end
