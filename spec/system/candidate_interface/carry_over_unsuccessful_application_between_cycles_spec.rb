require 'rails_helper'

RSpec.describe 'Candidate can carry over unsuccessful application to a new recruitment cycle between cycles' do
  around do |example|
    Timecop.freeze(Date.new(2020, 8, 1)) do
      example.run
    end
  end

  scenario 'when an unsuccessful candidate returns in the next recruitment cycle they can re-apply by carrying over their original application' do
    given_i_am_signed_in
    and_i_am_in_the_2020_recruitment_cycle
    and_i_have_an_application_with_a_rejection

    when_the_2020_apply2_deadline_passes
    and_i_visit_my_application_complete_page
    and_i_click_on_apply_again
    and_i_click_on_start_now

    then_i_can_see_application_details
    and_i_can_see_that_no_courses_are_selected_and_i_cannot_add_any_yet

    when_the_2021_cycle_opens
    and_i_visit_my_application_complete_page
    then_i_can_add_course_choices
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_am_in_the_2020_recruitment_cycle
    allow(RecruitmentCycle).to receive(:current_year).and_return(2020)
  end

  def and_i_have_an_application_with_a_rejection
    @application_form = create(:completed_application_form, :with_completed_references, candidate: @candidate)
    create(:application_choice, :with_rejection, application_form: @application_form)
  end

  def when_the_2020_apply2_deadline_passes
    Timecop.safe_mode = false
    Timecop.travel(Time.zone.local(2020, 9, 19, 12, 0, 0))
  ensure
    Timecop.safe_mode = true
  end

  def and_i_visit_my_application_complete_page
    logout
    login_as(@candidate)
    visit candidate_interface_application_complete_path
  end

  def and_i_click_on_apply_again
    expect(page).to have_content 'Do you want to continue applying?'
    click_link 'continue with your application'
  end

  def and_i_click_on_start_now
    expect(page).to have_content "Get your application ready to submit from #{EndOfCycleTimetable.apply_reopens.to_s(:govuk_date)}"
    expect(page).to have_content 'You\'ll have 3 course choices.'
    click_button 'Start now'
  end

  def and_i_click_go_to_my_application_form
    click_link 'Go to your application form'
  end

  def then_i_can_see_application_details
    expect(page).to have_content('Personal details Completed')
    click_link 'Personal details'
    expect(page).to have_content(@application_form.full_name)
    click_button 'Continue'
  end

  def and_i_can_see_that_no_courses_are_selected_and_i_cannot_add_any_yet
    expect(page).to have_content('You can apply for courses from 13 October.')
    expect(page).not_to have_link 'Course choice'
  end

  def when_the_2021_cycle_opens
    Timecop.safe_mode = false
    Timecop.travel(Time.zone.local(2020, 10, 13, 12, 0, 0))
    allow(RecruitmentCycle).to receive(:current_year).and_return(2021)
  ensure
    Timecop.safe_mode = true
  end

  def then_i_can_add_course_choices
    expect(page).to have_content('Course choice Incomplete')
    click_link 'Course choice'
    expect(page).to have_content 'You can apply for up to 3 courses'
  end
end
