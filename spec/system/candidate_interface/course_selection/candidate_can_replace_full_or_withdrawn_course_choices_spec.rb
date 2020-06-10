require 'rails_helper'

RSpec.describe 'A course option selected by a candidate has become full or been withdrawn' do
  include CandidateHelper
  include CourseOptionHelpers

  scenario 'when a candidate arrives at the dashboard they can follow the replace course flow' do
    given_the_replace_full_or_withdrawn_application_choices_is_active
    and_i_have_submitted_my_application
    and_one_of_my_application_choices_has_become_full
    and_another_course_exists

    when_i_arrive_at_my_application_dashboard
    then_i_see_that_one_of_my_choices_in_not_available

    given_i_have_two_full_course_choices

    when_i_arrive_at_my_application_dashboard
    then_i_see_that_multiple_choices_are_not_available

    when_i_click_update_my_course_choice
    then_i_see_the_replace_course_choices_page
    and_i_see_my_first_course_choice
    and_i_see_my_second_course_choice

    when_i_click_continue_without_selecting_an_option
    then_i_am_told_i_need_to_select_a_course_choice

    when_i_choose_my_first_course_choice
    and_click_continue
    then_i_arrive_at_the_replace_course_choice_page
    and_i_see_my_first_course_choice
  end

  def given_the_replace_full_or_withdrawn_application_choices_is_active
    FeatureFlag.activate('replace_full_or_withdrawn_application_choices')
  end

  def and_i_have_submitted_my_application
    candidate_completes_application_form
    candidate_submits_application
  end

  def and_one_of_my_application_choices_has_become_full
    @course_option = @application.application_choices.first.course_option
    @course_option.no_vacancies!
  end

  def and_another_course_exists
    course_option_for_provider(provider: @course_option.provider)
  end

  def when_i_arrive_at_my_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def then_i_see_that_one_of_my_choices_in_not_available
    expect(page).to have_content 'One of your choices is not available anymore.'
  end

  def given_i_have_two_full_course_choices
    @application_choice = create(:application_choice, application_form: @application, status: 'awaiting_references')
    @application_choice.course_option.no_vacancies!
  end

  def then_i_see_that_multiple_choices_are_not_available
    expect(page).to have_content 'Some of your choices are not available anymore.'
  end

  def when_i_click_update_my_course_choice
    click_link 'Update your course choice now'
  end

  def then_i_see_the_replace_course_choices_page
    expect(page).to have_current_path candidate_interface_replace_course_choices_path
  end

  def and_i_see_my_first_course_choice
    expect(page).to have_content(@course_option.course.name)
  end

  def and_i_see_my_second_course_choice
    expect(page).to have_content(@application_choice.course.name)
  end

  def when_i_click_continue_without_selecting_an_option
    click_button 'Continue'
  end

  def then_i_am_told_i_need_to_select_a_course_choice
    expect(page).to have_content 'Please select a course choice to update.'
  end

  def when_i_choose_my_first_course_choice
    choose "#{@course_option.provider.name} – #{@course_option.course.name_and_code}"
  end

  def and_click_continue
    when_i_click_continue_without_selecting_an_option
  end

  def then_i_arrive_at_the_replace_course_choice_page
    expect(page).to have_current_path candidate_interface_replace_course_choice_path(@course_option.application_choices.first.id)
  end
end
