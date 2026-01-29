require 'rails_helper'

RSpec.describe 'Carry over after the Apply Deadline' do
  include CandidateHelper

  before do
    set_time(after_apply_deadline)
  end

  scenario 'candidate carries over unsubmitted application after apply deadline' do
    given_i_have_unsubmitted_application

    when_i_sign_in
    then_i_see_the_recruitment_deadline_has_passed_content
    and_i_see_information_to_apply_for_the_next_academic_year
    and_i_do_not_see_the_add_course_button
    and_i_do_not_see_previous_applications_heading

    when_i_visit_add_course_url
    then_i_am_redirect_to_your_applications_tab

    when_i_visit_the_old_complete_page
    then_i_see_a_404_page
  end

  scenario 'candidate carries over submitted application after find opens deadline' do
    given_i_have_rejected_application
    and_today_is_after_find_reopens

    when_i_sign_in
    then_i_see_the_recruitment_deadline_has_passed_content
    and_i_see_information_to_apply_for_this_academic_year
    and_i_can_see_the_add_course_button
  end

private

  def given_i_have_unsubmitted_application
    @application_form = create(
      :application_form,
      :completed,
      :unsubmitted,
      date_of_birth: Date.new(1964, 9, 1),
      candidate: current_candidate,
    )
  end

  def given_i_have_rejected_application
    @application_form = create(
      :application_form,
      :completed,
      :submitted,
      date_of_birth: Date.new(1964, 9, 1),
      candidate: current_candidate,
    )

    create(
      :application_choice,
      :rejected,
      application_form: @application_form,
    )
  end

  def and_today_is_after_find_reopens
    next_timetable = @application_form.recruitment_cycle_timetable.relative_next_timetable
    TestSuiteTimeMachine.travel_permanently_to(next_timetable.find_opens_at + 1.second)
  end

  def when_i_sign_in
    login_as(current_candidate)
    visit root_path
  end

  def then_i_see_the_carry_over_content
    expect(page).to have_current_path candidate_interface_application_choices_path

    within 'form.button_to[action="/candidate/application/carry-over"]' do
      expect(page).to have_button 'Update your details'
    end
  end

  def when_i_carry_over
    click_link_or_button 'Update your details'
  end

  def then_i_am_redirected_to_the_your_details_page
    expect(page).to have_current_path candidate_interface_details_path
    then_i_see_a_copy_of_my_application
  end

  def then_i_see_a_404_page
    expect(page).to have_content 'Page not found'
  end

  def when_i_go_to_your_applications_tab
    click_link_or_button 'Your application'
  end

  def and_i_do_not_see_the_add_course_button
    expect(page).to have_no_content('Choose a course')
  end

  def and_i_can_see_the_add_course_button
    expect(page).to have_link('Choose a course', href: candidate_interface_course_choices_do_you_know_the_course_path)
  end

  def and_i_see_the_carried_over_banner
    application_form = current_candidate.current_application
    date_and_time_find_opens = application_form.find_opens_at.to_fs(:govuk_date_time_time_first)
    application_form_academic_year_range_name = application_form.academic_year_range_name
    date_and_time_apply_opens = application_form.apply_opens_at.to_fs(:govuk_date_time_time_first)

    expect(page).to have_content('You cannot submit applications at the moment')
    expect(page).to have_content("You can view and choose courses from #{date_and_time_find_opens}")
    expect(page).to have_content("You will be able to submit applications for the #{application_form_academic_year_range_name} recruitment cycle from #{date_and_time_apply_opens}.")
  end

  def and_i_do_not_see_previous_applications_heading
    expect(page).to have_no_content('Previous applications')
  end

  def when_i_visit_add_course_url
    visit candidate_interface_course_choices_do_you_know_the_course_path
  end

  def then_i_am_redirect_to_your_applications_tab
    expect(page).to have_current_path candidate_interface_application_choices_path
  end

  def when_i_visit_the_old_complete_page
    visit '/application/complete'
  end

  def then_i_see_a_copy_of_my_application
    expect(page).to have_title('Your details')

    click_link_or_button 'Personal information'
    expect(page).to have_content(Date.new(1964, 9, 1).to_fs(:govuk_date))
    and_my_application_is_on_the_new_cycle
  end

  def and_my_application_is_on_the_new_cycle
    current_year = @application_form.recruitment_cycle_year
    expect(current_candidate.current_application.reload.recruitment_cycle_year).to be(current_year + 1)
  end

  def then_i_see_the_recruitment_deadline_has_passed_content
    expect(page).to have_element(:h1, text: 'The recruitment deadline has now passed')
    expect(page).to have_element(
      :p,
      text: "The deadline for applying to courses in the #{@application_form.academic_year_range_name} " \
            'academic year has passed. You can no longer apply to courses starting in ' \
            "#{@application_form.recruitment_cycle_timetable.apply_deadline_at.to_fs(:month_and_year)}.",
    )
  end

  def and_i_see_information_to_apply_for_the_next_academic_year
    and_i_see_information_to_apply_for(RecruitmentCycleTimetable.next_timetable)
  end

  def and_i_see_information_to_apply_for_this_academic_year
    and_i_see_information_to_apply_for(RecruitmentCycleTimetable.current_timetable)
  end

  def and_i_see_information_to_apply_for(timetable)
    expect(page).to have_element(
      :h2,
      text: "Apply to courses in the #{timetable.academic_year_range_name} academic year",
    )
  end
end
