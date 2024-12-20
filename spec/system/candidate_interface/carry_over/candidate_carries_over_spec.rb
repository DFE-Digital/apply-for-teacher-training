require 'rails_helper'

RSpec.describe 'Carry over unsubmitted applications', :sidekiq do
  include CandidateHelper

  before do
    set_time(mid_cycle)
  end

  scenario 'candidate carries over unsubmitted application after apply deadline' do
    given_i_have_unsubmitted_application
    and_today_is_after_apply_deadline

    when_i_sign_in
    then_i_am_asked_to_carry_over

    when_i_carry_over
    then_i_am_redirected_to_continuous_application_details_page

    when_i_go_to_your_applications_tab
    then_i_do_not_see_the_add_course_button
    and_i_do_not_see_previous_applications_heading

    when_i_visit_add_course_url
    then_i_am_redirect_to_your_applications_tab

    when_i_visit_the_old_complete_page
    then_i_see_a_404_page
  end

  scenario 'candidate carries over unsubmitted application after find opens deadline' do
    given_i_have_unsubmitted_application
    and_today_is_after_find_reopens

    when_i_sign_in
    then_i_am_asked_to_carry_over

    when_i_carry_over
    then_i_am_redirected_to_continuous_application_details_page

    when_i_go_to_your_applications_tab
    then_i_do_not_see_the_add_course_button

    when_i_visit_add_course_url
    then_i_am_redirect_to_your_applications_tab

    when_i_visit_the_old_complete_page
    then_i_see_a_404_page
  end

  scenario 'candidate carries over submitted application after find opens deadline' do
    given_i_have_rejected_application
    and_today_is_after_find_reopens

    when_i_sign_in
    then_i_am_asked_to_carry_over

    when_i_carry_over
    then_i_am_redirected_to_continuous_application_details_page

    when_i_go_to_your_applications_tab
    then_i_do_not_see_the_add_course_button

    when_i_visit_add_course_url
    then_i_am_redirect_to_your_applications_tab

    when_i_visit_the_old_complete_page
    then_i_see_a_404_page
  end

private

  def given_i_have_unsubmitted_application
    @application_form = create(
      :completed_application_form,
      date_of_birth:,
      submitted_at: nil,
      candidate: current_candidate,
      recruitment_cycle_year: RecruitmentCycle.previous_year,
    )

    %i[not_requested_yet feedback_requested].each do |feedback_status|
      create(
        :reference,
        feedback_status:,
        application_form: @application_form,
      )
    end
  end

  def given_i_have_rejected_application
    @application_form = create(
      :completed_application_form,
      date_of_birth:,
      submitted_at: Time.zone.now,
      candidate: current_candidate,
      recruitment_cycle_year: 2023,
    )

    create(
      :application_choice,
      :rejected,
      application_form: @application_form,
    )
  end

  def given_i_have_rejected_application_in_apply_1_and_apply_again_from_2023
    given_i_have_rejected_application
    and_i_have_applied_again_in_2023
    and_i_have_submitted_apply_again_course_choices
  end

  def and_i_have_applied_again_in_2023
    DuplicateApplication.new(@application_form).duplicate
  end

  def given_i_have_submitted_application
    @application_form = create(
      :completed_application_form,
      date_of_birth:,
      submitted_at: Time.zone.now,
      candidate: current_candidate,
      recruitment_cycle_year: 2023,
    )

    create(
      :application_choice,
      :rejected,
      application_form: @application_form,
    )
  end

  def and_all_pending_applications_in_the_cycle_are_rejected
    ProcessStaleApplicationsWorker.perform_async
  end

  def and_today_is_after_apply_deadline
    TestSuiteTimeMachine.travel_permanently_to(after_apply_deadline)
  end
  alias_method :given_today_is_after_apply_deadline, :and_today_is_after_apply_deadline

  def given_today_is_after_rejected_by_default_date
    TestSuiteTimeMachine.travel_permanently_to(after_reject_by_default)
  end

  def and_today_is_after_find_reopens
    TestSuiteTimeMachine.travel_permanently_to(CycleTimetable.find_reopens)
  end

  def when_i_sign_in
    login_as(current_candidate)
    visit root_path
  end
  alias_method :and_i_sign_in, :when_i_sign_in

  def then_i_am_asked_to_carry_over
    expect(page).to have_current_path candidate_interface_start_carry_over_path
  end

  def and_i_have_submitted_apply_again_course_choices
    application_form = current_candidate.application_forms.find_by(phase: 'apply_2')
    create(:application_choice, :awaiting_provider_decision, application_form:)
    application_form.update!(submitted_at: Time.zone.now, becoming_a_teacher_completed: true)
  end

  def when_i_got_rejected_by_a_provider
    current_candidate.application_choices.awaiting_provider_decision.each do |application_choice|
      ApplicationStateChange.new(application_choice).reject!
      application_choice.update!(rejected_at: Time.zone.now)
    end
  end

  def when_i_carry_over
    click_link_or_button 'Update your details'
  end

  def then_i_am_redirected_to_continuous_application_details_page
    expect(page).to have_current_path candidate_interface_details_path
    then_i_see_a_copy_of_my_application
  end

  def then_i_see_a_404_page
    expect(page).to have_content 'Page not found'
  end

  def when_i_go_to_your_applications_tab
    click_link_or_button 'Your application'
  end

  def then_i_do_not_see_the_add_course_button
    expect(page).to have_no_content('Choose a courses')
    apply_reopen_date = I18n.l(CycleTimetable.apply_reopens.to_date, format: :no_year).strip
    cycle_range = CycleTimetable.cycle_year_range(RecruitmentCycle.next_year)
    expect(page).to have_content("From #{apply_reopen_date} you will be able to apply for courses starting in the #{cycle_range} academic year.")
  end

  def and_i_do_not_see_previous_applications_heading
    expect(page).to have_no_content('Previous applications')
  end

  def and_i_see_previous_applications_heading
    expect(page).to have_content('Previous applications')
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
    expect(page).to have_content(date_of_birth.to_fs(:govuk_date))
    and_my_application_is_on_the_new_cycle
  end

  def and_i_sign_in_again
    logout
    login_as(current_candidate)
    visit candidate_interface_details_path
  end

  def and_my_application_is_on_the_new_cycle
    year = RecruitmentCycle.next_year
    expect(current_candidate.current_application.reload.recruitment_cycle_year).to be(year)
  end

  def date_of_birth
    Date.new(1964, 9, 1)
  end
end
