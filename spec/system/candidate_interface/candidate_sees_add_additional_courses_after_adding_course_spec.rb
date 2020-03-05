require 'rails_helper'

RSpec.describe 'Add additional courses flow' do
  include CandidateHelper

  scenario 'Candidate is signed in' do
    given_that_add_additional_courses_page_is_active
    and_there_are_course_options
    and_i_am_signed_in

    when_i_visit_my_application_page
    and_i_click_on_course_choices
    and_i_click_on_add_course
    and_i_choose_that_i_know_where_i_want_to_apply

    when_i_choose_a_provider
    and_i_choose_my_first_course_choice
    then_i_should_be_on_the_add_additional_courses_page
    # and_i_should_receive_a_message_that_ive_added_the_first_course
    # and_i_should_be_told_i_can_add_2_more_courses
    # and_i_should_be_prompted_to_add_an_additional_course

    # when_i_add_an_additional_course
    # then_i_should_be_on_the_add_additional_courses_page
    # and_i_should_receive_a_message_that_ive_added_the_second_course
    # and_i_should_be_told_i_can_add_1_more_courses
    # and_i_should_be_prompted_to_add_an_additional_course
    #
    # when_i_add_a_third_course
    # then_i_should_be_on_the_add_additional_courses_page
    # and_i_should_receive_a_message_that_ive_added_the_third_course
  end

  def given_that_add_additional_courses_page_is_active
    FeatureFlag.activate('add_additional_courses_page')
  end

  def and_there_are_course_options
    @provider = create(:provider)
    3.times { create(:course, provider: @provider, exposed_in_find: true) }
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

  def and_i_choose_that_i_know_where_i_want_to_apply
    choose 'Yes, I know where I want to apply'
    click_button 'Continue'
  end

  def when_i_choose_a_provider
    select @provider.name_and_code
    click_button 'Continue'
  end

  def and_i_choose_my_first_course_choice
    choose @provider.courses.first.name_and_code
    click_button 'Continue'
  end

  def then_i_should_be_on_the_add_additional_courses_page
    # route to go here
  end
end
