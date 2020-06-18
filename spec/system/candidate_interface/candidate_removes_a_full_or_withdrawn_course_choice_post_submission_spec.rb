require 'rails_helper'

RSpec.describe 'Both a candidates course choices have become full or been withdrawn' do
  include CandidateHelper
  include CourseOptionHelpers

  scenario 'when a candidate arrives at the dashboard they can follow the replace course flow' do
    given_the_replace_full_or_withdrawn_application_choices_is_active?
    and_i_have_submitted_my_application
    and_both_of_my_application_choices_have_become_full

    when_i_arrive_at_my_application_dashboard
    and_i_click_update_my_course_choice
    and_i_choose_my_first_course_choice
    and_click_continue
    and_i_choose_to_remove_my_course
    and_click_continue
    then_i_see_the_confirm_destroy_page
    and_i_see_the_courses_details

    when_i_click_remove_my_course_choice
    then_i_arrive_on_my_second_full_course_choice_page

    when_i_choose_to_remove_my_course
    and_click_continue
    and_i_click_remove_my_course_choice
  end

  def given_the_replace_full_or_withdrawn_application_choices_is_active?
    FeatureFlag.activate('replace_full_or_withdrawn_application_choices')
  end

  def and_i_have_submitted_my_application
    candidate_completes_application_form
    candidate_submits_application
  end

  def and_both_of_my_application_choices_have_become_full
    @course_option = @application.application_choices.first.course_option
    @course_option.no_vacancies!
    course_option_for_provider(provider: @course_option.provider)
    @application_choice = create(:application_choice, application_form: @application, status: 'awaiting_references')
    @application_choice.course_option.no_vacancies!
  end

  def when_i_arrive_at_my_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def and_i_click_update_my_course_choice
    click_link 'Update your course choice now'
  end

  def and_i_choose_my_first_course_choice
    choose "#{@course_option.provider.name} – #{@course_option.course.name_and_code}"
  end

  def and_click_continue
    click_button 'Continue'
  end

  def and_i_choose_to_remove_my_course
    choose 'Remove course from application'
  end

  def then_i_see_the_confirm_destroy_page
    expect(page).to have_current_path candidate_interface_confirm_cancel_full_course_choice_path(@course_option.application_choices.first.id)
  end

  def and_i_see_the_courses_details
    expect(page).to have_content @course_option.course.name
  end

  def when_i_click_remove_my_course_choice
    click_link 'Remove course choice'
  end

  def then_i_arrive_on_my_second_full_course_choice_page
    expect(page).to have_current_path candidate_interface_replace_course_choice_path(@application_choice.id)
  end

  def when_i_choose_to_remove_my_course
    and_i_choose_to_remove_my_course
  end

  def and_i_click_remove_my_course_choice
    when_i_click_remove_my_course_choice
  end

  def then_i_see_the_confirm_withdraw_page
    expect(page).to have_current_path candidate_interface_confirm_withdraw_full_course_choice_path(@course_option.application_choices.first.id)
  end

  def when_i_click_withdraw_application
    click_link 'Yes - withdraw application'
  end

  def then_i_see_my_application_dashboard
    expect(page).to have_current_path candidate_interface_application_complete_path
  end

  def and_i_am_told_i_can_apply_again
    expect(page).to have_content 'Your application has been withdrawn.'
  end
end
