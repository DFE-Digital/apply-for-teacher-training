require 'rails_helper'

RSpec.feature 'Candidate applies for a course that has been held open' do
  include CandidateHelper

  scenario 'Candidate can apply for the course' do
    given_i_am_signed_in
    and_there_is_a_full_course
    and_there_is_a_full_course_that_has_been_held_open

    when_i_select_the_full_course
    then_i_see_a_page_telling_me_i_cannot_apply

    when_i_select_the_course_that_has_been_held_open
    then_i_can_apply_to_it
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_there_is_a_full_course
    @full_course = create(:course, :open_on_apply)

    create(:course_option, course: @full_course, vacancy_status: 'no_vacancies')
  end

  def and_there_is_a_full_course_that_has_been_held_open
    @full_course_held_open = create(:course, :open_on_apply, name: 'Basketweaving')

    create(:course_option, course: @full_course_held_open, vacancy_status: 'no_vacancies', hold_open: true)
  end

  def when_i_select_the_full_course
    visit candidate_interface_application_form_path
    click_link 'Course choices'
    click_link 'Continue'

    choose 'Yes, I know where I want to apply'
    click_button 'Continue'

    select @full_course.provider.name
    click_button 'Continue'

    choose @full_course.name
    click_button 'Continue'
  end

  def when_i_select_the_course_that_has_been_held_open
    visit candidate_interface_application_form_path
    click_link 'Course choices'
    click_link 'Continue'

    choose 'Yes, I know where I want to apply'
    click_button 'Continue'

    select @full_course_held_open.provider.name
    click_button 'Continue'

    choose @full_course_held_open.name
    click_button 'Continue'
  end

  def then_i_see_a_page_telling_me_i_cannot_apply
    expect(page).to have_text('You cannot apply to this course because it has no vacancies')
    expect(page).to have_text("The course ‘#{@full_course.name_and_code}’ is full")
  end

  def then_i_can_apply_to_it
    expect(page).to have_text('You’ve added Basketweaving')
  end
end
