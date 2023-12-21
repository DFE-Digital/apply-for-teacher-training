require 'rails_helper'

RSpec.feature 'Carry over', :continuous_applications, skip: 'Carry over does not work in 2024', time: CycleTimetableHelper.mid_cycle(2024) do
  include CandidateHelper

  it 'Candidate carries over unsubmitted application with a course to new cycle' do
    given_i_am_signed_in_as_a_candidate
    when_i_have_an_unsubmitted_application
    and_the_recruitment_cycle_ends
    and_the_cancel_unsubmitted_applications_worker_runs

    when_i_sign_in_again
    and_i_visit_the_application_dashboard
    then_i_am_redirected_to_the_carry_over_interstitial

    when_i_click_on_continue
    then_i_see_a_copy_of_my_application

    when_i_view_referees
    then_i_can_see_the_referees_i_previously_added

    when_i_view_courses
    then_i_can_see_that_i_need_to_select_courses

    when_i_add_a_course
    and_i_complete_the_section
    and_i_visit_the_course_choices_section
    then_i_see_the_course_choice_review_page

    when_i_add_another_course
    and_i_complete_the_section
    and_i_receive_references
    and_i_submit_my_application
    then_my_application_is_awaiting_provider_decision
  end

  def given_i_am_signed_in_as_a_candidate
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def when_i_have_an_unsubmitted_application
    @application_form = create(
      :completed_application_form,
      :eligible_for_free_school_meals,
      :with_gcses,
      submitted_at: nil,
      candidate: @candidate,
      safeguarding_issues_status: :no_safeguarding_issues_to_declare,
      references_count: 0,
    )
    @application_choice = create(
      :application_choice,
      status: :unsubmitted,
      application_form: @application_form,
    )
    @first_reference = create(
      :reference,
      feedback_status: :not_requested_yet,
      application_form: @application_form,
    )
    @second_reference = create(
      :reference,
      feedback_status: :feedback_requested,
      application_form: @application_form,
    )
  end

  def and_the_recruitment_cycle_ends
    advance_time_to(after_apply_reopens)
  end

  def and_the_cancel_unsubmitted_applications_worker_runs
    CancelUnsubmittedApplicationsWorker.new.perform
  end

  def when_i_sign_in_again
    logout
    login_as(@candidate)
  end

  def and_i_visit_the_application_dashboard
    visit candidate_interface_continuous_applications_details_path
  end

  def then_i_am_redirected_to_the_carry_over_interstitial
    expect(page).to have_current_path candidate_interface_start_carry_over_path
  end

  def when_i_click_on_continue
    click_button 'Continue'
  end

  def then_i_see_a_copy_of_my_application
    expect(page).to have_title('Your application')
  end

  def when_i_view_referees
    click_link 'References to be requested if you accept an offer'
  end

  def then_i_can_see_the_referees_i_previously_added
    expect(page).to have_css('h3', text: @first_reference.name)
    expect(page).to have_css('h3', text: @second_reference.name)
  end

  def when_i_view_courses
    click_link 'Back to application'
  end

  def then_i_can_see_that_i_need_to_select_courses
    expect(page).to have_content('You can apply for up to 4 courses')
  end

  def when_i_add_a_course
    given_courses_exist
    click_link 'Choose your course'

    choose 'Yes, I know where I want to apply'
    click_button t('continue')

    select 'Gorse SCITT (1N1)'
    click_button t('continue')

    choose 'Primary (2XT2)'
    click_button t('continue')

    expect(page).to have_content('Primary (2XT2)')
    expect(page).to have_content('You can add 3 more courses')
  end

  def and_i_visit_the_course_choices_section
    click_link 'Choose your courses'
  end

  def then_i_see_the_course_choice_review_page
    expect(page).to have_current_path candidate_interface_course_choices_review_path
  end

  def when_i_add_another_course
    click_link 'Add another course'

    choose 'Yes, I know where I want to apply'
    click_button t('continue')

    select 'Gorse SCITT (1N1)'
    click_button t('continue')

    choose 'Drama (2397)'
    click_button t('continue')

    expect(page).to have_content('Drama (2397)')
    expect(page).to have_content('You can add 2 more course')
  end

  def and_i_complete_the_section
    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def and_i_receive_references
    receive_references
    mark_references_as_complete
  end

  def and_i_submit_my_application
    @new_application_form = candidate_submits_application
  end

  def then_my_application_is_awaiting_provider_decision
    application_choice = @new_application_form.application_choices.first
    expect(application_choice.status).to eq('awaiting_provider_decision')
  end
end
