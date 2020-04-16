require 'rails_helper'

RSpec.feature 'Adding a course' do
  include DfESignInHelpers

  scenario 'A support user adds a course to a application' do
    given_i_am_a_support_user
    and_there_is_a_candidate_who_wants_a_course_added
    when_i_visit_the_application_form
    and_click_on_the_button_to_change_courses
    and_i_select_the_option_to_add_a_course
    and_i_fill_in_the_course_option_id_for_the_desired_course
    then_the_new_course_is_added_to_the_application
    and_i_can_no_longer_add_a_course_because_3_is_the_max
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_a_candidate_who_wants_a_course_added
    @application_form = create(:completed_application_form)

    create(:application_choice, status: 'awaiting_references', application_form: @application_form)
    create(:application_choice, status: 'awaiting_references', application_form: @application_form)

    @new_course_option = create(:course_option, course: create(:course, name: 'A new course'))
  end

  def when_i_visit_the_application_form
    visit support_interface_application_form_path(@application_form)
  end

  def and_click_on_the_button_to_change_courses
    click_on 'Make changes to courses'
  end

  def and_i_select_the_option_to_add_a_course
    choose 'Add a course'
    click_on 'Continue'
  end

  def and_i_fill_in_the_course_option_id_for_the_desired_course
    fill_in 'Course Option ID', with: @new_course_option.id
    click_on 'Add course to application'
  end

  def then_the_new_course_is_added_to_the_application
    expect(page).to have_content 'A new course'
  end

  def and_i_can_no_longer_add_a_course_because_3_is_the_max
    click_on 'Make changes to courses'

    expect(page).to have_content 'You can no longer add a course because this application already has 3'

    visit support_interface_add_course_to_application_path(@application_form)

    expect(page).to have_content 'This application already has 3 courses'
  end
end
