require 'rails_helper'

RSpec.describe 'Candidate can carry over unsuccessful application to a new recruitment cycle after the apply deadline' do
  include CandidateHelper

  before do
    TestSuiteTimeMachine.travel_permanently_to(mid_cycle(2023))
  end

  scenario 'when an unsuccessful candidate returns in the next recruitment cycle they can re-apply by carrying over their original application' do
    given_i_am_signed_in
    and_i_have_an_application_with_a_rejection

    when_the_apply_deadline_passes
    and_i_visit_my_application_complete_page
    then_i_see_the_carry_over_inset_text

    when_the_next_cycle_opens
    and_i_visit_my_application_complete_page
    and_i_carry_over_my_application
    then_i_can_add_course_choices
  end

  scenario 'Candidate can see the add another job button in the new cycle' do
    given_i_am_signed_in
    and_i_have_an_application_with_a_rejection
    and_the_apply_deadline_passes
    and_i_visit_my_application_complete_page
    and_i_carry_over_my_application
    and_the_next_cycle_opens
    and_i_visit_my_application_complete_page
    and_i_click_on_work_history
    then_i_see_the_add_another_job_button
  end

  def and_i_click_on_work_history
    click_link_or_button 'Work history'
  end

  def then_i_see_the_add_another_job_button
    expect(page).to have_link('Add another job', href: '/candidate/application/restructured-work-history/new', class: 'govuk-button govuk-button--secondary')
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_an_application_with_a_rejection
    @application_form = create(:completed_application_form, :with_completed_references, candidate: @candidate)
    create(:application_choice, :rejected, application_form: @application_form)

    job = create(:application_work_experience, application_form: @application_form)
    @application_form.application_work_experiences << [job]
  end

  def when_the_apply_deadline_passes
    advance_time_to(after_apply_deadline)
  end

  def and_i_visit_my_application_complete_page
    logout
    login_as(@candidate)
    visit candidate_interface_application_complete_path
  end

  def and_i_click_go_to_my_application_form
    click_link_or_button 'Go to your application form'
  end

  def then_i_see_the_carry_over_inset_text
    next_recruitment_year_range = CycleTimetable.cycle_year_range(CycleTimetable.next_year)
    expect(page).to have_content "You can apply for courses starting in the #{next_recruitment_year_range} academic year instead."
  end

  def when_the_next_cycle_opens
    advance_time_to(after_apply_reopens)
  end

  def and_i_carry_over_my_application
    click_link_or_button 'Apply again'
  end

  alias_method :and_the_apply_deadline_passes, :when_the_apply_deadline_passes
  alias_method :and_the_next_cycle_opens, :when_the_next_cycle_opens
end
