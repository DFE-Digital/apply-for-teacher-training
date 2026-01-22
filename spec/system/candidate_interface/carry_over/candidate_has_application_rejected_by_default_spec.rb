require 'rails_helper'

RSpec.describe 'Candidate has an application where provider does not make a decision' do
  include CandidateHelper

  before do
    TestSuiteTimeMachine.travel_permanently_to(mid_cycle)
    @timetable = current_timetable
    @candidate = create(:candidate)
  end

  context 'Application choice is awaiting provider decisions' do
    scenario 'Candidate can carry over only after application is rejected by default' do
      given_i_have_an_application_awaiting_provider_decision
      and_the_apply_deadline_has_passed
      when_i_sign_in
      and_i_navigate_to_my_applications
      then_i_see_my_application_is_awaiting_provider_decision
      then_i_cannot_carry_over_my_application

      when_the_reject_by_default_deadline_has_passed
      and_i_sign_in
      and_i_navigate_to_my_applications
      then_i_see_the_recruitment_deadline_page
      and_i_see_information_to_apply_for_the_next_academic_year
    end
  end

  context 'Application choice is inactive' do
    scenario 'Candidate can carry over only after application is rejected by default' do
      given_i_have_an_inactive_application
      and_the_apply_deadline_has_passed
      when_i_sign_in
      and_i_navigate_to_my_applications
      then_i_see_my_application_is_inactive
      then_i_cannot_carry_over_my_application

      when_the_reject_by_default_deadline_has_passed
      and_i_sign_in
      and_i_navigate_to_my_applications
      then_i_see_the_recruitment_deadline_page
      and_i_see_information_to_apply_for_the_next_academic_year
    end
  end

  context 'Application choice is interviewing' do
    scenario 'Candidate can carry over only after application is rejected by default' do
      given_i_have_an_application_with_interviewing_status
      and_the_apply_deadline_has_passed
      when_i_sign_in
      and_i_navigate_to_my_applications
      then_i_see_my_application_is_interviewing
      then_i_cannot_carry_over_my_application

      when_the_reject_by_default_deadline_has_passed
      and_i_sign_in
      and_i_navigate_to_my_applications
      then_i_see_the_recruitment_deadline_page
      and_i_see_information_to_apply_for_the_next_academic_year
    end
  end

private

  def given_i_have_an_application_awaiting_provider_decision
    @awaiting_provider_decision_application = create(:application_choice, :awaiting_provider_decision, candidate: @candidate)
  end

  def given_i_have_an_application_with_interviewing_status
    @interviewing_application = create(:application_choice, :interviewing, candidate: @candidate)
  end

  def given_i_have_an_inactive_application
    @inactive_application = create(:application_choice, :inactive, candidate: @candidate)
  end

  def and_the_apply_deadline_has_passed
    advance_time_to(cancel_application_deadline + 1.second)
    EndOfCycle::CancelUnsubmittedApplicationsWorker.perform_sync
  end

  def when_i_sign_in
    logout
    login_as @candidate
    visit root_path
  end
  alias_method :and_i_sign_in, :when_i_sign_in

  def and_i_navigate_to_my_applications
    click_on 'Your applications'
  end

  def then_i_see_my_application_is_awaiting_provider_decision
    expect(page).to have_current_path candidate_interface_application_choices_path
    expect(page).to have_content 'Awaiting decision'
  end

  def then_i_see_my_application_is_inactive
    expect(page).to have_current_path candidate_interface_application_choices_path
    expect(page).to have_content 'Inactive'
  end

  def then_i_see_my_application_is_interviewing
    expect(page).to have_content 'Interviewing'
  end

  def then_i_see_my_application_is_now_unsuccessful
    expect(page).to have_content 'Unsuccessful'
  end

  def then_i_cannot_carry_over_my_application
    expect(page).to have_current_path candidate_interface_application_choices_path
    expect(page).to have_content(
      'Applications that are awaiting provider decision or interviewing will be rejected automatically.',
    )
  end
  alias_method :and_i_cannot_carry_over_my_application, :then_i_cannot_carry_over_my_application

  def and_i_can_carry_over_my_application
    click_on 'Update your details'
    expect(page).to have_current_path candidate_interface_details_path
  end

  def when_the_reject_by_default_deadline_has_passed
    advance_time_to(reject_by_default_run_date)
    EndOfCycle::RejectByDefaultWorker.perform_sync
  end

  def then_i_see_the_recruitment_deadline_page
    application_form = @candidate.current_application.previous_application_form
    expect(page).to have_current_path candidate_interface_application_choices_path
    expect(page).to have_element(:h1, text: 'The recruitment deadline has now passed')
    expect(page).to have_element(
      :p,
      text: "The deadline for applying to courses in the #{application_form.academic_year_range_name} " \
            'academic year has passed. You can no longer apply to courses starting in ' \
            "#{application_form.recruitment_cycle_timetable.apply_deadline_at.to_fs(:month_and_year)}.",
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
