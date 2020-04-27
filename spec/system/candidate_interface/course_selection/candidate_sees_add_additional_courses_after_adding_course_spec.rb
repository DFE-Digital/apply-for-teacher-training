require 'rails_helper'

RSpec.describe 'Add additional courses flow' do
  include CandidateHelper
  include CourseOptionHelpers

  scenario 'Candidate is signed in' do
    given_there_are_course_options
    and_i_am_signed_in

    when_i_visit_my_application_page
    and_i_click_on_course_choices
    and_i_click_on_add_course

    when_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider
    and_i_choose_my_first_course_choice
    then_i_should_be_on_the_add_additional_courses_page
    and_i_should_receive_a_message_that_ive_added_the_first_course
    and_i_should_be_told_i_can_add_2_more_courses
    and_i_should_be_prompted_to_add_an_additional_course

    when_i_choose_no
    then_i_should_be_on_the_course_choice_review_page

    given_i_am_on_the_additional_courses_page
    when_i_choose_yes
    then_i_should_see_the_have_you_chosen_a_course_page

    when_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider
    and_i_choose_my_second_course_choice
    then_i_should_be_on_the_add_additional_courses_page
    and_i_should_receive_a_message_that_ive_added_the_second_course
    and_i_should_be_told_i_can_add_1_more_courses
    and_i_should_be_prompted_to_add_an_additional_course

    when_i_choose_yes
    then_i_should_see_the_have_you_chosen_a_course_page

    when_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider
    and_i_choose_my_third_course_choice
    then_i_should_be_on_the_course_choice_review_page
    and_i_should_receive_a_message_that_ive_added_the_third_course
  end

  def given_there_are_course_options
    @provider = create(:provider)
    create_list(:course, 3, provider: @provider, exposed_in_find: true, open_on_apply: true, study_mode: :full_time)
    course_option_for_provider(provider: @provider, course: @provider.courses.first)
    course_option_for_provider(provider: @provider, course: @provider.courses.second)
    course_option_for_provider(provider: @provider, course: @provider.courses.third)
  end

  def and_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_visit_my_application_page
    visit candidate_interface_application_form_path
  end

  def and_i_click_on_course_choices
    click_link 'Course choices'
  end

  def and_i_click_on_add_course
    click_link 'Continue'
  end

  def when_i_choose_that_i_know_where_i_want_to_apply
    choose 'Yes, I know where I want to apply'
    click_button 'Continue'
  end

  def and_i_choose_a_provider
    select @provider.name_and_code
    click_button 'Continue'
  end

  def and_i_choose_my_first_course_choice
    choose @provider.courses.first.name_and_code
    click_button 'Continue'
  end

  def then_i_should_be_on_the_add_additional_courses_page
    expect(page).to have_current_path candidate_interface_course_choices_add_another_course_path
  end

  def and_i_should_receive_a_message_that_ive_added_the_first_course
    expect(page).to have_content("You’ve added #{@provider.courses.first.name_and_code} to your application")
  end

  def and_i_should_be_told_i_can_add_2_more_courses
    expect(page).to have_content('You can choose 2 more courses')
  end

  def and_i_should_be_prompted_to_add_an_additional_course
    expect(page).to have_content('Do you want to add another course?')
  end

  def when_i_choose_no
    choose 'No, not at the moment'
    click_on 'Continue'
  end

  def given_i_am_on_the_additional_courses_page
    visit candidate_interface_course_choices_add_another_course_path
  end

  def when_i_choose_yes
    choose 'Yes, add another course'
    click_on 'Continue'
  end

  def then_i_should_see_the_have_you_chosen_a_course_page
    expect(page).to have_current_path(candidate_interface_course_choices_choose_path)
  end

  def and_i_should_receive_a_message_that_ive_added_the_second_course
    expect(page).to have_content("You’ve added #{@provider.courses.second.name_and_code} to your application")
  end

  def and_i_choose_my_second_course_choice
    choose @provider.courses.second.name_and_code
    click_button 'Continue'
  end

  def and_i_should_be_told_i_can_add_1_more_courses
    expect(page).to have_content('You can choose 1 more course')
  end

  def and_i_choose_my_third_course_choice
    choose @provider.courses.third.name_and_code
    click_button 'Continue'
  end

  def then_i_should_be_on_the_course_choice_review_page
    expect(page).to have_current_path(candidate_interface_course_choices_review_path)
  end

  def and_i_should_receive_a_message_that_ive_added_the_third_course
    expect(page).to have_content("You’ve added #{@provider.courses.third.name_and_code} to your application")
  end
end
