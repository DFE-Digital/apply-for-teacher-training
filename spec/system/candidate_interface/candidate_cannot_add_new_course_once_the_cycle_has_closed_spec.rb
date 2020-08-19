require 'rails_helper'

RSpec.describe 'Candidate vists their applicatin form after the cycle has ended' do
  include CandidateHelper

  around do |example|
    Timecop.freeze(EndOfCycleTimetable.apply_1_deadline) do
      example.run
    end
  end

  scenario 'The candidate cannot add new courses to their application form' do
    given_i_am_signed_in
    and_my_application_forms_phase_is_apply_1
    and_it_is_the_day_before_the_apply_1_deadline

    when_i_visit_the_site
    then_there_is_a_link_to_the_course_choices_section

    given_it_is_the_day_after_the_apply1_deadline

    when_i_visit_the_site
    then_i_see_that_i_can_add_new_course_choices_in_october
    and_there_is_not_a_link_to_the_course_choices_section

    when_i_click_review_your_application
    then_i_see_that_i_can_add_new_course_choices_in_october

    when_i_try_to_visit_the_pick_provider_page
    then_i_am_redirected_back_to_the_application_form

    given_the_new_cycle_is_open
    and_i_logout
    and_i_am_signed_in

    when_i_visit_the_site
    then_there_is_a_link_to_the_course_choices_section

    given_my_application_forms_phase_is_apply_2
    and_it_is_the_day_before_the_apply_2_deadline

    when_i_visit_the_site
    then_there_is_a_link_to_the_course_choices_section

    given_it_is_the_day_after_the_apply2_deadline

    when_i_visit_the_site
    then_i_see_that_i_can_add_new_course_choices_in_october
    and_there_is_not_a_link_to_the_course_choices_section

    given_the_new_cycle_is_open
    and_i_logout
    and_i_am_signed_in

    when_i_visit_the_site
    then_there_is_a_link_to_the_course_choices_section

    given_it_is_before_before_the_apply_1_deadline
    and_i_have_submitted_my_application
    and_the_apply_1_deadline_passes
    and_one_of_my_courses_has_become_full

    when_i_arrive_at_my_application_dashboard
    then_i_see_do_not_see_the_banner_to_replace_my_course_choice
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_my_application_forms_phase_is_apply_1; end

  def and_it_is_the_day_before_the_apply_1_deadline; end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def then_there_is_a_link_to_the_course_choices_section
    expect(page).to have_link('Course choices')
  end

  def given_it_is_the_day_after_the_apply1_deadline
    Timecop.travel(EndOfCycleTimetable.apply_1_deadline + 1.day)
  end

  def then_i_see_that_i_can_add_new_course_choices_in_october
    expect(page).to have_content 'You can apply for courses from 13 October.'
  end

  def and_there_is_not_a_link_to_the_course_choices_section
    expect(page).not_to have_link('Course choices')
  end

  def when_i_click_review_your_application
    click_link 'Review your application'
  end

  def when_i_try_to_visit_the_pick_provider_page
    visit candidate_interface_course_choices_provider_path
  end

  def then_i_am_redirected_back_to_the_application_form
    expect(page).to have_current_path candidate_interface_application_form_path
  end

  def given_the_new_cycle_is_open
    Timecop.travel(EndOfCycleTimetable.next_cycle_opens + 1.day)
  end

  def and_i_logout
    logout
  end

  def and_i_am_signed_in
    given_i_am_signed_in
  end

  def given_my_application_forms_phase_is_apply_2
    current_candidate.current_application.apply_2!
  end

  def and_it_is_the_day_before_the_apply_2_deadline
    Timecop.travel(EndOfCycleTimetable.apply_2_deadline)
  end

  def given_it_is_the_day_after_the_apply2_deadline
    Timecop.travel(EndOfCycleTimetable.apply_2_deadline + 1.day)
  end

  def given_it_is_the_day_before_the_apply_2_deadline
    and_it_is_the_day_before_the_apply_2_deadline
  end

  def given_it_is_before_before_the_apply_1_deadline
    Timecop.travel(EndOfCycleTimetable.apply_1_deadline)
  end

  def and_i_have_submitted_my_application
    current_candidate.current_application.destroy!
    candidate_completes_application_form
    candidate_submits_application
  end

  def and_the_apply_1_deadline_passes
    given_it_is_the_day_after_the_apply1_deadline
  end

  def and_one_of_my_courses_has_become_full
    current_candidate.current_application.application_choices.first.course_option.no_vacancies!
  end

  def when_i_arrive_at_my_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def then_i_see_do_not_see_the_banner_to_replace_my_course_choice
    expect(page).not_to have_content 'One of your choices is not available anymore.'
  end
end
