require 'rails_helper'

RSpec.feature 'Candidate applies for a course that has been held open' do
  include CandidateHelper

  scenario 'Candidate can apply for the course' do
    and_the_hold_courses_open_feature_flag_is_off

    given_i_am_signed_in
    and_there_is_a_full_course

    when_i_select_the_full_course
    then_i_see_a_page_telling_me_i_cannot_apply

    when_the_hold_courses_open_feature_flag_is_on

    when_i_select_the_full_course
    then_i_can_apply_to_it
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_the_hold_courses_open_feature_flag_is_off
    FeatureFlag.deactivate(:hold_courses_open)
  end

  def when_the_hold_courses_open_feature_flag_is_on
    FeatureFlag.activate(:hold_courses_open)
  end

  def and_there_is_a_full_course
    @full_course = create(:course, :open_on_apply)

    create(:course_option, course: @full_course, vacancy_status: 'no_vacancies')
  end

  def when_i_select_the_full_course
    visit candidate_interface_application_form_path
    click_link 'Choose your courses'
    click_link t('continue')

    choose 'Yes, I know where I want to apply'
    click_button t('continue')

    select @full_course.provider.name
    click_button t('continue')

    choose @full_course.name
    click_button t('continue')
  end

  def then_i_see_a_page_telling_me_i_cannot_apply
    expect(page).to have_text('You cannot apply to this course because it has no vacancies')
    expect(page).to have_text("The course ‘#{@full_course.name_and_code}’ is full")
  end

  def then_i_can_apply_to_it
    expect(page).to have_text("You’ve added #{@full_course.name_and_code}")
  end
end
